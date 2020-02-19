package com.javarush.task.task19.task1902;

/* 
Адаптер
*/

import java.io.FileOutputStream;
import java.io.IOException;

public class AdapterFileOutputStream implements AmigoStringWriter {
    private FileOutputStream fileOutputStream;

    public AdapterFileOutputStream(FileOutputStream fileOutputStream) {
        this.fileOutputStream = fileOutputStream;
    }

    public static void main(String[] args) throws IOException {
        AmigoStringWriter amigoStringWriter = new AdapterFileOutputStream(new FileOutputStream("f:\\1\\112.txt"));
        amigoStringWriter.writeString("Тест Testing String 2020\r\n");
        amigoStringWriter.close();
    }


    @Override
    public void flush() throws IOException {
        fileOutputStream.flush();
    }

    @Override
    public void writeString(String s) throws IOException {
        byte[] bytes = s.getBytes() ;
        fileOutputStream.write(bytes);
    }

    @Override
    public void close() throws IOException {
        fileOutputStream.close();
    }
}

