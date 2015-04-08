package com.mymobilerobots.rk1digital.app;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.CompoundButton;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.net.UnknownHostException;


public class MainActivity extends Activity {

    TextView ipaddressTextView;
    TextView portnumberTextView;
    TextView voltageTextView;

    String ipaddress;
    int portnumber;

    Switch d10switch;
    Switch d11switch;
    Switch d12switch;
    Switch d13switch;

    boolean d10state;
    boolean d11state;
    boolean d12state;
    boolean d13state;

    Socket socket = null;

    DataInputStream dataInputStream = null;
    DataOutputStream dataOutputStream = null;

    Handler handler = new Handler();

    float voltage = 0.0f;

    connectOperation task;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this);

        ipaddressTextView = (TextView) findViewById(R.id.ipaddressTextView);
        portnumberTextView = (TextView) findViewById(R.id.portnumberTextView);
        voltageTextView = (TextView) findViewById(R.id.voltageTextView);

        ipaddress = sharedPreferences.getString("prefipaddress", "192.168.1.1");
        portnumber = sharedPreferences.getInt("prefportnumber", 2000);

        ipaddressTextView.setText(ipaddress);
        portnumberTextView.setText(String.valueOf(portnumber));

        d10switch = (Switch) findViewById(R.id.d10switch);
        d10switch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
             @Override
             public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                d10state = b;
             }
         });

        d11switch = (Switch) findViewById(R.id.d11switch);
        d11switch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                d11state = b;
            }
        });

        d12switch = (Switch) findViewById(R.id.d12switch);
        d12switch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                d12state = b;
            }
        });

        d13switch = (Switch) findViewById(R.id.d13switch);
        d13switch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                d13state = b;
            }
        });

        task = new connectOperation();
        task.execute();
    }

    @Override
    protected void onResume() {
        super.onResume();

        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this);

        ipaddressTextView = (TextView) findViewById(R.id.ipaddressTextView);
        portnumberTextView = (TextView) findViewById(R.id.portnumberTextView);

        ipaddress = sharedPreferences.getString("prefipaddress", "192.168.1.1");
        portnumber = sharedPreferences.getInt("prefportnumber", 2000);

        ipaddressTextView.setText(ipaddress);
        portnumberTextView.setText(String.valueOf(portnumber));

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_settings) {
            Intent i = new Intent(this, UserSettingsActivity.class);
            startActivityForResult(i, 1);

            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private Runnable runnable = new Runnable() {
        @Override
        public void run() {
            int d10 = (d10state) ? 1 : 0;
            int d11 = (d11state) ? 1 : 0;
            int d12 = (d12state) ? 1 : 0;
            int d13 = (d13state) ? 1 : 0;
            byte[] buffer = {3,(byte)d10,(byte)d11,(byte)d12,(byte)d13};
            task.sendAction(buffer);
            //byte[] data = {2,0,0,0,0};
            //task.sendAction(data);
            handler.postDelayed(this, 330);
        }
    };

    private class connectOperation extends AsyncTask<Void, Void, Void> {

        @Override
        protected Void doInBackground(Void... params){

            try {
                socket = new Socket(ipaddress, portnumber);
                dataOutputStream = new DataOutputStream(socket.getOutputStream());
                dataInputStream = new DataInputStream(socket.getInputStream());

                handler.postDelayed(runnable, 330);

                while(true)
                {
                    byte[] buffer = new byte[4096];
                    int read = dataInputStream.read(buffer);
                    if (read > 0)
                    {
                        int updatevalue = (buffer[2] << 8) + buffer[1];
                        voltage =  updatevalue * (5.0f / 1023.0f);

                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                voltageTextView.setText(String.format("%.2fv", voltage));
                            }
                        });
                    }
                }


            } catch (UnknownHostException e) {
                e.printStackTrace();

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(getApplicationContext(), "Connection failed", Toast.LENGTH_LONG).show();
                    }
                });
            } catch (IOException e) {
                e.printStackTrace();

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(getApplicationContext(), "Connection failed", Toast.LENGTH_LONG).show();
                    }
                });
            }

            return null;
        }

        @Override
        protected void onPostExecute(Void result)
        {
            super.onPostExecute(result);
        }

        @Override
        protected void onPreExecute() {}

        @Override
        protected void onProgressUpdate(Void... values) {}

        public void sendAction(byte[] buffer)
        {
            try {
                dataOutputStream.write(buffer);
                dataOutputStream.flush();

            } catch (UnknownHostException e) {
                e.printStackTrace();

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(getApplicationContext(), "Connection failed", Toast.LENGTH_LONG).show();
                    }
                });
            } catch (IOException e) {
                e.printStackTrace();

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(getApplicationContext(), "Connection failed", Toast.LENGTH_LONG).show();
                    }
                });
            }
        }
    }

}
