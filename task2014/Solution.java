package com.javarush.task.task20.task2014;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.Date;

/* 
Serializable Solution
*/
public class Solution implements Serializable {
    public static void main(String[] args) {

        Solution savedObject = new Solution(4);
        System.out.println(savedObject);

        try (FileOutputStream fos = new FileOutputStream("zad14.dat");
            ObjectOutputStream oos = new ObjectOutputStream(fos)) {
            System.out.println("------------Сжимаемый---------------");
            System.out.println(savedObject.string);
            oos.writeObject(savedObject);

        } catch (IOException e) {
            e.printStackTrace();
        }

        try (FileInputStream fis = new FileInputStream("zad14.dat");
            ObjectInputStream ois = new ObjectInputStream(fis)) {

            Solution loadedObject = (Solution) ois.readObject();
            System.out.println("--------------Надутый------------");
            System.out.println(loadedObject.string);

            //Проверка поля объектов на идентичность
            System.out.println(savedObject.string.equals(loadedObject.string));

        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }


    private final transient String pattern = "dd MMMM yyyy, EEEE";
    private transient Date currentDate;
    private transient int temperature;
    String string;

    public Solution(int temperature) {
        this.currentDate = new Date();
        this.temperature = temperature;

        string = "Today is %s, and the current temperature is %s C";
        SimpleDateFormat format = new SimpleDateFormat(pattern);
        this.string = String.format(string, format.format(currentDate), temperature);
    }

    @Override
    public String toString() {
        return this.string;
    }

}
