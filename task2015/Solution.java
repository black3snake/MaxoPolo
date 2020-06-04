package com.javarush.task.task20.task2015;

import java.io.*;

/* 
Переопределение сериализации
*/
public class Solution implements Serializable,Runnable {
    private transient Thread runner;
    private int speed;

    public Solution(int speed) {
        this.speed = speed;
        runner = new Thread(this);
        runner.start();
    }

    @Override
    public void run() {
        // do something here, doesn't matter what
        for (int i = 0; i < 5 ; i++) {
            System.out.println(Thread.currentThread() + "Дочерняя нить считает - " + i);
        }
    }

    /**
     * Переопределяем сериализацию.
     * Для этого необходимо объявить методы:
     * private void writeObject(ObjectOutputStream out) throws IOException
     * private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException
     * Теперь сериализация/десериализация пойдет по нашему сценарию :)
     */
    private void writeObject(ObjectOutputStream out) throws IOException {
        out.defaultWriteObject();
    }

    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        in.defaultReadObject();
        Solution sol2 = this;
        Thread thread2 = new Thread(sol2);
        thread2.start();
    }

    public static void main(String[] args) {
        Solution sol = new Solution(3);
        try(FileOutputStream fos = new FileOutputStream("zad15.dat");
            ObjectOutputStream oos = new ObjectOutputStream(fos)) {
            oos.writeObject(sol);
            oos.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }

        try(FileInputStream fis = new FileInputStream("zad15.dat");
            ObjectInputStream ois = new ObjectInputStream(fis)) {
            Solution solRes = (Solution) ois.readObject();
            System.out.println(solRes.speed);

        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }


}
