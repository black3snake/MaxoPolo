package com.javarush.task.task18.task1823;

import java.io.*;
import java.util.*;

/* 
Нити и байты
Валя приняла с первой попытки :-)
*/

public class Solution {
    public volatile static Map<String, Integer> resultMap = new HashMap<>();

    public static void main(String[] args) throws IOException, InterruptedException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        List<Thread> threads = new ArrayList<>();
        String fileN;
        ReadThread readThread;
        //ThreadGroup threadGroup = new ThreadGroup("GROUP1");
        while (!(fileN = reader.readLine()).equals("exit")) {
            readThread = new ReadThread(fileN);
            threads.add(readThread);
            readThread.start();
        }
        reader.close();
        for(Thread s : threads) {
            s.join();
            //System.out.println("Ожидаю коня " + s.getName());
        }

        for(Map.Entry<String,Integer> pair : resultMap.entrySet()) {
            System.out.println(pair.getKey() + " " + pair.getValue());
        }
    }

    public static class ReadThread extends Thread {
        private String filename;
        //ThreadGroup group;
        Map<Byte,Integer> map = new HashMap<>();
        //public ReadThread(ThreadGroup group, String fileName, String name) {
        public ReadThread(String fileName) {
            //super(name);
            this.filename = fileName;
            //this.group = group;
            //implement constructor body
        }

        @Override
        public void run() {
            //Thread current = Thread.currentThread();
            //while (!current.isInterrupted()) {
                FileInputStream in;
                try {
                    in = new FileInputStream(filename);
                    int i;
                    Integer am;
                    while ((i = in.read()) != -1) {
                        am = map.get((byte) i);
                        map.put((byte) i, am == null ? 1 : am + 1);
                    }
                    Collection<Integer> valuesC = map.values();
                    Integer max = Collections.max(valuesC);
                    System.out.println();
                    Byte Key = null;
                    for (Map.Entry<Byte, Integer> pair : map.entrySet()) {
                        if (pair.getValue().equals(max)) {
                            Key = pair.getKey();
                        }
                    }
                 //   System.out.println("Поток: " + Thread.currentThread() + " Key<Byte>:" + Key + " Max = " + max);
                    in.close();
                 //   synchronized (ReadThread.class) {

                            Solution.resultMap.put(filename, (int) Key);

                   // }
                } catch (FileNotFoundException |NullPointerException e) {
                    System.out.println("Файл не найден");
                } catch (IOException e) {
                    e.printStackTrace();
                }

            //}
        }
        // implement file reading here - реализуйте чтение из файла тут
    }
}
