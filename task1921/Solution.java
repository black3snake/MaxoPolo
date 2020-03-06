package com.javarush.task.task19.task1921;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/* 
Хуан Хуанович
*/

public class Solution {
    public static final List<Person> PEOPLE = new ArrayList<Person>();

    public static void main(String[] args) {
        SimpleDateFormat df = new SimpleDateFormat("dd MM yyyy");
        if (args.length > 0) {
            FileReader fr;
            BufferedReader buffR;
            try {
                fr = new FileReader(args[0]);
                buffR = new BufferedReader(fr);
                String str,str2,str3;
                StringBuilder sb = new StringBuilder();
                while ((str = buffR.readLine()) != null) {
                    str2 = str.replaceAll("\\d+", "").trim();
                    //str3 = str.replaceAll("([a-zA-Z\\W])","");
                    String[] strM = str.split("\\s");
                    for (int i = 0; i < strM.length ; i++) {
                        if (strM[i].matches("\\d+")) {
                            sb.append(strM[i]).append(" ");
                        }
                    }
                    Date d2 = df.parse(sb.toString().trim());
                    sb.delete(0,sb.length());
                    //System.out.println(str2 + " - " + d2.toString());
                    PEOPLE.add(new Person(str2,d2));
                }
                buffR.close();
                fr.close();
            } catch (FileNotFoundException | ParseException e) {
                System.out.println("Такого файла нет :(");
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else {
            System.out.println("введите к качестве параметра имя файла и путь до него");
        }
      /*for (int i = 0; i <PEOPLE.size() ; i++) {
            System.out.println(PEOPLE.get(i));
        }*/
    }
}
