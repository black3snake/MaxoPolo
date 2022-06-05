package com.javarush.task.task20.task2020;

import java.io.*;
import java.util.logging.Logger;

/* 
Сериализация человека
*/
public class Solution {

    public static class Person implements Serializable {
        String firstName;
        String lastName;
        transient String fullName;
        transient final String greeting;
        String country;
        Sex sex;
        transient PrintStream outputStream;
        transient Logger logger;

        Person(String firstName, String lastName, String country, Sex sex) {
            this.firstName = firstName;
            this.lastName = lastName;
            this.fullName = String.format("%s, %s", lastName, firstName);
            this.greeting = "Hello, ";
            this.country = country;
            this.sex = sex;
            this.outputStream = System.out;
            this.logger = Logger.getLogger(String.valueOf(Person.class));
        }
    }

    enum Sex {
        MALE,
        FEMALE
    }

    public static void main(String[] args) throws IOException, ClassNotFoundException {

        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        ObjectOutputStream oos = new ObjectOutputStream(bos);
        /*Solution sol = new Solution();
        Person person = sol.new Person("Иван","Иванов","Россия", Sex.MALE);*/   // Решение для не статик класса
        Person person = new Person("Иван","Иванов","Россия", Sex.MALE);
        System.out.println(person.firstName + " " + person.lastName + " " + person.country + " " +
                person.sex);
        System.out.println("-------------- Сжимаем -----");
        oos.writeObject(person);

        ByteArrayInputStream bis = new ByteArrayInputStream(bos.toByteArray());
        ObjectInputStream ois = new ObjectInputStream(bis);

        Person perRes = (Person) ois.readObject();
        System.out.println("----------------Надуваем -------");
        System.out.println(perRes.firstName + " " + perRes.lastName + " " + perRes.country + " " +
                perRes.sex);

    }
}
