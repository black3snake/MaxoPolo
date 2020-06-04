package com.javarush.task.task20.task2015;

import java.io.*;

/* 
Переопределение сериализации
Нашел в книге, что помогло с решением данной задачи.
Однако, существует другое странное и хитрое решение.
Используя встроенную возможность механизма сериализации, разработчики могут
реализовать нормальный процесс поместив в свои файлы классов два метода:

private void writeObject(ObjectOutputStream out) throws IOException;
private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException;
Обратите внимание, что оба метода (совершенно справедливо), объявлены как private,
поскольку это гарантирует что методы не будут переопределены или перезагружены.
Весь фокус в том, что виртуальная машина при вызове соответствующего метода автоматически проверяет,
не были ли они объявлены в классе объекта. Виртуальная машина в любое время может вызвать private
методы вашего класса, но другие объекты этого сделать не смогут.
Таким образом обеспечивается целостность класса и нормальная работа протокол сериализации.
Протокол сериализации всегда используется одинаково, путем вызова ObjectOutputStream.writeObject()
или ObjectInputStream.readObject(). Таким образом, даже если в классе присутствуют эти специализированные
private методы, сериализация объектов будет работать так же, как и для любых других вызываемых объектов.
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
        // теперь мы вновь получили "живой" объект, поэтому давайте перестроим и запустим его
        //
        runner = new Thread(this);
        runner.start();
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
