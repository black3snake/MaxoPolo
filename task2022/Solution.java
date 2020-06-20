package com.javarush.task.task20.task2022;

import java.io.*;

/*
Переопределение сериализации в потоке
*/
public class Solution implements Serializable, AutoCloseable {
    transient private FileOutputStream stream;
    private String fileName;

    public Solution(String fileName) throws FileNotFoundException {
        this.fileName = fileName;
        this.stream = new FileOutputStream(fileName);
    }

    public void writeObject(String string) throws IOException {
        stream.write(string.getBytes());
        stream.write("\n".getBytes());
        stream.flush();
    }

    private void writeObject(ObjectOutputStream out) throws IOException {
        out.defaultWriteObject();
    }

    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        in.defaultReadObject();
        stream = new FileOutputStream(fileName,true);
    }

    @Override
    public void close() throws Exception {
        System.out.println("Closing everything!");
        stream.close();
    }

    public static void main(String[] args) throws Exception {
        Solution solution = new Solution("zad22.dat");
        solution.writeObject("Test №7711");

        ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("zad22.dat"));
        oos.writeObject(solution);
        oos.close();
        solution.close();

        ObjectInputStream ois = new ObjectInputStream(new FileInputStream("zad22.dat"));
        Solution solRes = (Solution) ois.readObject();
        ois.close();


        System.out.println(solRes.toString() +" ---------");
        System.out.println(solRes.fileName);

        solRes.writeObject("Test №772");
        solRes.close();
    }
}
