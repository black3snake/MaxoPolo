package com.javarush.task.task19.task1927;

/* 
Контекстная реклама
*/

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

public class Solution {
    public static TestString testString = new TestString();

    public static void main(String[] args) {
        PrintStream consoleC = System.out;
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        PrintStream stream = new PrintStream(byteArrayOutputStream);
        StringBuilder sb = new StringBuilder();
        System.setOut(stream);
        testString.printSomething();
        System.setOut(consoleC);
        String [] strM = byteArrayOutputStream.toString().split(System.getProperty("line.separator"));
        for (int i = 0; i < strM.length ; i++) {
            if (i != 0) {
                if (i % 2 == 0) {
                    sb.append("JavaRush - курсы Java онлайн").append(System.getProperty("line.separator"));
                }
            }
            //System.out.println(strM[i]);
            sb.append(strM[i]).append(System.getProperty("line.separator"));
        }
        System.out.print(sb.toString());
    }

    public static class TestString {
        public void printSomething() {
            System.out.println("first");
            System.out.println("second");
            System.out.println("third");
            System.out.println("fourth");
            System.out.println("fifth");
        }
    }
}
