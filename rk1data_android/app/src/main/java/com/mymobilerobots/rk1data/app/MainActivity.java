package com.mymobilerobots.rk1data.app;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.UnknownHostException;


public class MainActivity extends Activity {

    TextView ipaddressTextView;
    TextView portnumberTextView;
    TextView voltageTextView;

    String ipaddress;
    int portnumber;

    ServerSocket serverSocket = null;
    Socket socket = null;

    DataInputStream dataInputStream = null;
    DataOutputStream dataOutputStream = null;

    Handler handler = new Handler();

    float voltage = 0.0f;

    connectOperation task;

    ArrayAdapter<String> adapter;

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

        task = new connectOperation();
        task.execute();
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

    private Runnable runnable = new Runnable() {
        @Override
        public void run() {
            byte[] data = {2,0,0,0,0};
            task.sendAction(data);
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

                        String[] myItems = {"A0: " + String.valueOf((buffer[2] << 8) + buffer[1]), "A1: " + String.valueOf((buffer[4] << 8) + buffer[3]),
                                "A2: " + String.valueOf((buffer[6] << 8) + buffer[5]), "A3: " + String.valueOf((buffer[8] << 8) + buffer[7]),
                                "A4: " + String.valueOf((buffer[10] << 8) + buffer[9]), "A5: " + String.valueOf((buffer[12] << 8) + buffer[11]),
                                "A6: " + String.valueOf((buffer[14] << 8) + buffer[13]), "A7: " + String.valueOf((buffer[16] << 8) + buffer[15])};

                        adapter = new ArrayAdapter<String>(MainActivity.this, R.layout.listitem, myItems);

                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                ListView list = (ListView) findViewById(R.id.datalistView);
                                list.setAdapter(adapter);
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
