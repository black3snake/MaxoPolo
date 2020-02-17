package com.javarush.task.task18.task1828;

/* 
Прайсы 2
*/

import java.io.*;
import java.util.*;

public class Solution {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        String fileName = reader.readLine();
        FileInputStream fileInputStream = new FileInputStream(fileName);
        BufferedReader br = new BufferedReader(new InputStreamReader(fileInputStream,"windows-1251"));
        reader.close();
        List<String> list = new ArrayList<>();
        String str;

        if(args.length > 0) {
            ArgsIn argsIn = new ArgsIn(args);

            while ((str = br.readLine()) != null && !str.equals("")) {
                list.add(str+"\r\n");
            }
            br.close();
            fileInputStream.close();

            switch (argsIn.Key) {
                case "-d":
                    Iterator<String> it = list.iterator(); //создаем итератор
                    while (it.hasNext()) { //до тех пор, пока в списке есть элементы
                        String nextString = it.next(); //получаем следующий элемент
                        long idf = Long.parseLong(nextString.substring(0,8).trim());
                        if(argsIn.getID() == idf) {
                                it.remove();
                        }
                    }
                    System.out.println(argsIn.Key + " " + argsIn.getID());
                    for(String st : list ) {
                        System.out.print(st);  //выведим в консоль состояние изменненного ArrayList
                    }
                    break;
                case "-u":
                    ListIterator<String> it2 = list.listIterator(); //создаем итератор
                    while (it2.hasNext()) { //до тех пор, пока в списке есть элементы
                        String nextString = it2.next(); //получаем следующий элемент
                        long idf = Long.parseLong(nextString.substring(0,8).trim());
                        if(argsIn.getID() == idf) {
                            String forma = String.format("%-8d%-30s%-8s%-4s\r\n", argsIn.getID(),argsIn.getProdN(),argsIn.getPrice(),argsIn.getQuantity());
                            it2.set(forma);   //вносим изменения
                        }
                    }
                    System.out.print(argsIn.Key + " ");
                    System.out.println(argsIn.getID() + " " + argsIn.getProdN() + " " + argsIn.getPrice() + " " + argsIn.getQuantity());

                    for(String st : list ) {
                        System.out.print(st);  //выведим в консоль состояние изменненного ArrayList
                    }
                    break;
                default:
                    System.out.println("Нужно использовать -u(изменить), -d(удалить).");
            }
            // Запишем результат в файл.
            FileOutputStream fileOutputStream = new FileOutputStream(fileName);
            BufferedWriter out = new BufferedWriter(new OutputStreamWriter(fileOutputStream,"windows-1251")); // Валя не принимает с кодировкой но для того чтобы было читаемо и считаю так правильно!
            for (String s : list) {
                out.write(s);
            }
            out.close();
            fileOutputStream.close();
        } else {
            System.out.println("Введите Аргументы..");
        }
    }
}
class ArgsIn {
    private String[] ar;
    private String price;
    private String quantity;
    private String prodN;
    int Len;
    String Key;
    private long ID;
    StringBuilder sbArg = new StringBuilder();
    public ArgsIn(String[] ar) {
        this.ar = ar;
        this.Len = ar.length;
        this.Key = ar[0];
        setProdN();
        setPrice();
        setQuantity();
        setID();
    }
    private void setProdN() {
        if(Len > 2) {
            for (int i = 2; i < ar.length - 2; i++) {
                sbArg.append(ar[i]).append(" ");
            }
            this.prodN = sbArg.toString().trim();
            sbArg.delete(0, sbArg.length());
        }
    }
    public String getProdN() {
        return prodN;
    }
    private void setPrice() {
       if (Len > 2 & ar.length-2 != 0 )
           this.price = ar[ar.length-2];
    }
    public String getPrice() {
        return price;
    }
    private void setQuantity() {
        if(Len > 2 & ar.length-1 != 0 )
        this.quantity = ar[ar.length-1];
    }
    public String getQuantity() {
        return quantity;
    }
    private void setID() {
        if(!ar[1].isEmpty() & isNumeric(ar[1]))
        this.ID = Long.parseLong(ar[1]);
    }
    public long getID() {
        return ID;
    }
    private boolean isNumeric(String str) {
        return str.matches("\\d+(\\.\\d+)?");
    }
}
