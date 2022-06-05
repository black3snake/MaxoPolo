package com.javarush.task.task19.task1904;

import java.io.FileInputStream;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Scanner;

/* 
И еще один адаптер
Адаптировать Scanner к PersonScanner.
Классом-адаптером является PersonScannerAdapter.
В классе адаптере создать приватное финальное поле Scanner fileScanner. Поле инициализировать в конструкторе с одним аргументом типа Scanner.

Данные в файле хранятся в следующем виде:
Иванов Иван Иванович 31 12 1950
Петров Петр Петрович 31 12 1957

В файле хранится большое количество людей, данные одного человека находятся в одной строке. Метод read() должен читать данные только одного человека.
*/

public class Solution {

    public static void main(String[] args) throws IOException, ParseException {
//        filescanner = new Scanner(new FileInputStream("f:\\1\1122.txt"), "windows-1251");
        PersonScanner personScanner = new PersonScannerAdapter(new Scanner(new FileInputStream("f:\\1\\1122.txt"), "windows-1251"));
        Person person = personScanner.read();
        System.out.println(person.toString());
        personScanner.close();
    }

    public static class PersonScannerAdapter implements PersonScanner {
        private Scanner fileScanner;
        public PersonScannerAdapter(Scanner fileScanner) {
            this.fileScanner = fileScanner;
        }
        @Override
        public Person read() throws IOException, ParseException {
            String [] str = this.fileScanner.nextLine().split(" ");
            SimpleDateFormat df = new SimpleDateFormat("dd MM yyyy");
            Date d2 = df.parse(str[3] + " " + str[4] + " " + str[5]);
            return new Person (str[1],str[2],str[0], d2);
        }
        @Override
        public void close() throws IOException {
                this.fileScanner.close();
        }
    }
}
