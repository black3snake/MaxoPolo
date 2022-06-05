package com.javarush.task.task18.task1824;

/* 
Файлы и исключения
Задача решена с помощью Theads, а Валя хочет просто ... эх как я всё усложнил :-)) хотя
это очень полезно изучать многопотоковое программирование.
Здесь идет перехват сообщения от коня:-) который в момент старта обнаружил что нет дороги по которой надо 
бежать и крикнул -> его крик услышал главный распорядитель и остановил весь забег коней :-)
*/

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class Solution {
    public static Thread.UncaughtExceptionHandler handler = new OurUncaughtExceptionHandler();
    public static List<Thread> thlist = new ArrayList<>();

    public static void main(String[] args) {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        String filename;
        try {
            while (!(filename = reader.readLine()).isEmpty()) {
                WorkThread commonT = new WorkThread(handler, filename);
                Thread thread = new Thread(commonT);
                thlist.add(thread);
                thread.start();
            }
            for (Thread t : thlist) {
                //System.out.println("Список нитей " + t.getName());
                t.join();
            }
        } catch (InterruptedException | IOException e) {
            e.printStackTrace();
        }
	reader.close();
    }

    public static class OurUncaughtExceptionHandler implements Thread.UncaughtExceptionHandler {

        @Override
        public void uncaughtException(Thread t, Throwable e) {
            for (Thread t2 : thlist) {
                t2.interrupt();
            }
            System.out.println(e.getMessage());
            //System.out.println(t.getName() + ": " + e.getMessage());
            //System.out.println("Кинул INTERRUPT всем потокам");
        }
    }
}

class WorkThread extends Thread {
        String fileN;
        public WorkThread(Thread.UncaughtExceptionHandler handler, String fileN) {
            setDefaultUncaughtExceptionHandler(handler);
            this.fileN = fileN;
        }
        @Override
        public void run() {
            try {
                FileInputStream in = new FileInputStream(fileN);
                int i;
                while ((i = in.read()) != -1) {
                    sleep(100);
                    System.out.print((char)i );
                }
                System.out.println();
                System.out.println("TIK " + Thread.currentThread());
                in.close();

            } catch (FileNotFoundException e) {
                //System.out.println("** RuntimeException from thread");
                //throw new RuntimeException("exception from thread " + fileN);
                throw new RuntimeException(fileN);

            } catch (InterruptedException | IOException e) {
                //System.out.println(Thread.currentThread() +" Обнаружил кинутое Прерывание");
            }
        }
}
