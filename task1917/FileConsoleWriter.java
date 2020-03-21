package com.javarush.task.task19.task1917;

/* 
Свой FileWriter
Реализовать логику FileConsoleWriter.
Класс FileConsoleWriter должен содержать приватное поле FileWriter fileWriter.
Класс FileConsoleWriter должен содержать все конструкторы, которые инициализируют fileWriter для записи.
Класс FileConsoleWriter должен содержать пять методов write и один метод close:

При записи данных в файл, должен дублировать эти данные на консоль.
*/

import java.io.File;
import java.io.FileDescriptor;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays;

public class FileConsoleWriter {
    private FileWriter fileWriter;

   public  FileConsoleWriter(String str) throws  IOException {
       fileWriter = new FileWriter(String.valueOf(str));
   }

    public FileConsoleWriter(String str, boolean append) throws IOException {
        fileWriter = new FileWriter(str, append);
    }

    public FileConsoleWriter(File file) throws IOException {
        fileWriter = new FileWriter(file);
    }

    public FileConsoleWriter(File file, boolean append) throws IOException {
        fileWriter = new FileWriter(file,append);
    }

    public FileConsoleWriter(FileDescriptor fd) {
        fileWriter = new FileWriter(fd);
    }

   /* public FileConsoleWriter(String str, Charset charset) throws IOException {
        fileWriter = new FileWriter(str, charset);
    }

    public FileConsoleWriter(String str, Charset charset, boolean append) throws IOException {
        fileWriter = new FileWriter(str, charset, append);
    }


    public FileConsoleWriter(File file, Charset charset) throws IOException {
        fileWriter = new FileWriter(file, charset);
    }

    public FileConsoleWriter(File file, Charset charset, boolean append) throws IOException {
        fileWriter = new FileWriter(file,charset);
   }*/

    public static void main(String[] args) throws IOException {
            //FileConsoleWriter fw = new FileConsoleWriter("f:\\1\\1.txt");
            FileConsoleWriter fw = new FileConsoleWriter("f:\\1\\1.txt",true);
            int i = 69;
            fw.write(i);

            char [] ch = {'a','b','c','d','e'};
            fw.write(ch, 0, ch.length-1);
            fw.write(ch);

            String str = "Добрый день || ";
            fw.write(str);
            fw.write(str,2,3);

            fw.close();

    }

    public void write(char[] cbuf, int off, int len) throws IOException {
        fileWriter.write(cbuf, off, len);
        System.out.println(Arrays.copyOfRange(cbuf,off,off+len));
    }

    public void write(int c) throws IOException {
        fileWriter.write(c);
        System.out.println(c);
    }

    public void write(String str) throws IOException {
        fileWriter.write(str);
        System.out.println(str);
    }

    public void write(String str, int off, int len) throws IOException {
        fileWriter.write(str, off, len);
        System.out.println(str.substring(off, off+len));
    }
    public void write(char[] cbuf) throws IOException {
        fileWriter.write(cbuf);
        System.out.println(cbuf);
    }

    public void close() throws IOException {
        fileWriter.close();
    }
}
