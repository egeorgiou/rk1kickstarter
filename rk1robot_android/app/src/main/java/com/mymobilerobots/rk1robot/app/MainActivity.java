package com.mymobilerobots.rk1robot.app;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.GestureDetector;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.widget.TextView;
import android.widget.Toast;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.UnknownHostException;

public class MainActivity extends Activity implements GestureDetector.OnGestureListener, GestureDetector.OnDoubleTapListener {

    private static final String PUBLIC_KEY = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhxYc44bTRtQnE3769Xx7EUIe9EP/iXdSchtv59ektzH0bYVXW05o7/cLKg8CH39IP6M3VsBGmSnqD3zfC6c7ZvBH5G3RCBK6QCskikfqxy0riFFGhRsZoFlNkojvXWWmy3iL0s9f/GW/4mpXUQ7c6aZxKIXngkGfsmOKn5L19rBWgoONPX7xX9c6xYOQ2z3UhTUZaAVjl8/Z93wMWlyI9aD8Z7Jz7i3M7O6q3+q//yDUuF2xEpJZvDmzrFBzZOMzwGFR9kxBubvc60BYyf+F8aHWuL1STyDcURcpuSir+5RtLh+3p6rtwHiVfu3KLju3+X6ottWDuqba0JptD0WexQIDAQAB";

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

    public static int left;
    public static int right;
    public static Boolean leftDirection;
    public static Boolean rightDirection;

    public static TextView lefttextview;
    public static TextView righttextview;

    private static final String DEBUG_TAG = "Gestures";
    private GestureDetector mDetector;

    final private int SWIPE_MIN_DISTANCE = 100;
    final private int SWIPE_MIN_VELOCITY = 100;

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

        leftDirection = false;
        rightDirection = false;

        lefttextview = (TextView) findViewById(R.id.lefttextView);
        left = 0;
        lefttextview.setText(String.valueOf(left));

        righttextview = (TextView) findViewById(R.id.righttextView);
        right = 0;
        righttextview.setText(String.valueOf(right));

        mDetector = new GestureDetector(this, this);
        mDetector.setOnDoubleTapListener(this);

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
            int leftD = (leftDirection) ? 1 : 0;
            int rightD = (rightDirection) ? 1 : 0;
            byte[] buffer = {1,(byte)leftD,(byte)left,(byte)rightD,(byte)right};
            task.sendAction(buffer);
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

    @Override
    public boolean onTouchEvent(MotionEvent event){
        this.mDetector.onTouchEvent(event);
        // Be sure to call the superclass implementation
        return super.onTouchEvent(event);
    }

    @Override
    public boolean onDown(MotionEvent event) {
        //Log.d(DEBUG_TAG,"onDown: " + event.toString());
        return true;
    }

    @Override
    public boolean onFling(MotionEvent event1, MotionEvent event2,
                           float velocityX, float velocityY) {
        //Log.d(DEBUG_TAG, "onFling: " + event1.toString()+event2.toString());

        try {
            final float ev1x = event1.getX();
            final float ev1y = event1.getY();
            final float ev2x = event2.getX();
            final float ev2y = event2.getY();
            final float xdiff = Math.abs(ev1x - ev2x);
            final float ydiff = Math.abs(ev1y - ev2y);
            final float xvelocity = Math.abs(velocityX);
            final float yvelocity = Math.abs(velocityY);

            if(xvelocity > this.SWIPE_MIN_VELOCITY && xdiff > this.SWIPE_MIN_DISTANCE)
            {
                if(ev1x > ev2x) //Swipe Left
                {
                    Log.d(DEBUG_TAG, "onFling: Swipe Left");
                    swipeLeft();
                }
                else //Swipe Right
                {
                    Log.d(DEBUG_TAG, "onFling: Swipe Right");
                    swipeRight();
                }
            }
            else if(yvelocity > this.SWIPE_MIN_VELOCITY && ydiff > this.SWIPE_MIN_DISTANCE)
            {
                if(ev1y > ev2y) //Swipe Up
                {
                    Log.d(DEBUG_TAG, "onFling: Swipe Up");
                    swipeUp();
                }
                else //Swipe Down
                {
                    Log.d(DEBUG_TAG, "onFling: Swipe Down");
                    swipeDown();
                }
            }

            return false;
        } catch (Exception e) {

        }

        return false;
    }

    @Override
    public void onLongPress(MotionEvent event) {
        //Log.d(DEBUG_TAG, "onLongPress: " + event.toString());
    }

    @Override
    public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX,
                            float distanceY) {
        //Log.d(DEBUG_TAG, "onScroll: " + e1.toString()+e2.toString());
        return true;
    }

    @Override
    public void onShowPress(MotionEvent event) {
        //Log.d(DEBUG_TAG, "onShowPress: " + event.toString());
    }

    @Override
    public boolean onSingleTapUp(MotionEvent event) {
        //Log.d(DEBUG_TAG, "onSingleTapUp: " + event.toString());
        return true;
    }

    @Override
    public boolean onDoubleTap(MotionEvent event) {
        //Log.d(DEBUG_TAG, "onDoubleTap: " + event.toString());

        Log.d(DEBUG_TAG, "onDoubleTap: Swipe Stop");
        swipeStop();

        return true;
    }

    @Override
    public boolean onDoubleTapEvent(MotionEvent event) {
        //Log.d(DEBUG_TAG, "onDoubleTapEvent: " + event.toString());
        return true;
    }

    @Override
    public boolean onSingleTapConfirmed(MotionEvent event) {
        //Log.d(DEBUG_TAG, "onSingleTapConfirmed: " + event.toString());
        return true;
    }

    public static void swipeUp()
    {
        if (leftDirection == false)
        {
            left = left + 50;

            if (left > 250)
            {
                left = 250;
            }
        }
        else if (leftDirection == true)
        {
            left = left - 50;

            if (left < 0)
            {
                left = 50;

                leftDirection = false;
                lefttextview.setTextColor(Color.BLACK);
            }
        }

        if (rightDirection ==  false)
        {
            right = right + 50;

            if (right > 250) {
                right = 250;
            }

        }
        else if (rightDirection == true)
        {
            right = right - 50;

            if (right < 0)
            {
                right = 50;

                rightDirection = false;
                righttextview.setTextColor(Color.BLACK);
            }
        }

        lefttextview.setText(String.valueOf(left));
        righttextview.setText(String.valueOf(right));
    }

    public static void swipeDown()
    {
        if (leftDirection ==  false)
        {
            left = left - 50;

            if (left < 0) {
                left = 50;

                leftDirection = true;
                lefttextview.setTextColor(Color.RED);
            }

        }
        else if (leftDirection == true)
        {
            left = left + 50;

            if (left > 250)
            {
                left = 250;
            }
        }

        if (rightDirection ==  false)
        {
            right = right - 50;

            if (right < 0) {
                right = 50;

                rightDirection = true;
                righttextview.setTextColor(Color.RED);
            }

        }
        else if (rightDirection == true)
        {
            right = right + 50;

            if (right > 250)
            {
                right = 250;
            }
        }

        lefttextview.setText(String.valueOf(left));
        righttextview.setText(String.valueOf(right));
    }

    public static void swipeLeft()
    {
        if (leftDirection ==  false)
        {
            left = left + 50;

            if (left > 250) {
                left = 250;
            }

        }
        else if (leftDirection == true)
        {
            left = left - 50;

            if (left < 0)
            {
                left = 50;

                leftDirection = false;
                lefttextview.setTextColor(Color.BLACK);
            }
        }

        if (rightDirection ==  false)
        {
            right = right - 50;

            if (right < 0) {
                right = 50;

                rightDirection = true;
                righttextview.setTextColor(Color.RED);
            }

        }
        else if (rightDirection == true)
        {
            right = right + 50;

            if (right > 250)
            {
                right = 250;
            }
        }

        lefttextview.setText(String.valueOf(left));
        righttextview.setText(String.valueOf(right));
    }

    public static void swipeRight()
    {
        if (leftDirection ==  false)
        {
            left = left - 50;

            if (left < 0) {
                left = 50;

                leftDirection = true;
                lefttextview.setTextColor(Color.RED);
            }

        }
        else if (leftDirection == true)
        {
            left = left + 50;

            if (left > 250)
            {
                left = 250;
            }
        }

        if (rightDirection ==  false)
        {
            right = right + 50;

            if (right > 250) {
                right = 250;
            }

        }
        else if (rightDirection == true)
        {
            right = right - 50;

            if (right < 0)
            {
                right = 50;

                rightDirection = false;
                righttextview.setTextColor(Color.BLACK);
            }
        }

        lefttextview.setText(String.valueOf(left));
        righttextview.setText(String.valueOf(right));
    }

    public static void swipeStop()
    {
        leftDirection = false;
        rightDirection = false;

        left = 0;
        right = 0;

        lefttextview.setTextColor(Color.BLACK);
        righttextview.setTextColor(Color.BLACK);

        lefttextview.setText(String.valueOf(left));
        righttextview.setText(String.valueOf(right));
    }
}
