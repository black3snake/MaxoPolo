package com.javarush.task.task17.task1711;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

/* 
CRUD 2
*/

public class Solution {
    public static volatile List<Person> allPeople = new ArrayList<Person>();

    static {
        allPeople.add(Person.createMale("Иванов Иван", new Date()));  //сегодня родился    id=0
        allPeople.add(Person.createMale("Петров Петр", new Date()));  //сегодня родился    id=1
    }

    public static void main(String[] args) throws ParseException {
        //start here - начни тут
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        List<String> strings;

        switch (args[0]) {
            case "-i":
                //System.out.println("количество элементов(параметров) :" + args.length);
                synchronized (allPeople) {
                for (int i=1; i< args.length; i++) {
                   // System.out.println("Элемент N "+ i +" - " + args[i]);
                    int id = Integer.parseInt(args[i]);
                        new SpecialThread(id, "info");
                    }
                }
                break;
            case "-d":
                //System.out.println("Удаляем");
                synchronized (allPeople) {
                for (int i=1; i< args.length; i++) {
                    int id = Integer.parseInt(args[i]);
                        new SpecialThread(id, "delete");
                    }
                }
                break;
            case "-c":
                //System.out.println("Создаем");
                synchronized (allPeople) {
                int A2 = (args.length-1)/3;
                strings = new ArrayList<>(Arrays.asList(args));
                strings.remove(0);
                    for (int i = 1; i <= A2; i++) {
                        new SpecialThread(strings.get(0), strings.get(1), dateFormat.parse(strings.get(2)), "create");
                        strings = remove(strings, 3);
                    }
                }

                break;
            case "-u":
                //System.out.println("Модифицируем");
                synchronized (allPeople) {
                int A4 = (args.length-1)/4;
                strings = new ArrayList<>(Arrays.asList(args));
                strings.remove(0);
                    for (int i = 1; i <= A4; i++) {
                        new SpecialThread(Integer.parseInt(strings.get(0)), strings.get(1), strings.get(2), dateFormat.parse(strings.get(3)), "update");
                        strings = remove(strings, 4);
                    }
                }

                break;
            default:
                synchronized (allPeople) {

                }
                System.out.println("Введите параметры. \n -i id1 id2 id3 id4 ... \n -d id1 id2 id3 id4 ... \n -c name1 sex1 bd1 name2 sex2 bd2 ... \n -u id1 name1 sex1 bd1 id2 ..");
        }
    }
    public static List remove(List list, int ARcount) {
        if (ARcount == 3) {
            for(int i=0; i < ARcount; i++ ) {
                  list.remove(0);
            }
        } else if (ARcount == 4) {
            for(int i=0; i < ARcount; i++ ) {
                list.remove(0);
            }
        }
    return list;
    }
}
class SpecialThread implements Runnable {
    private int id2;
    private String thname;
    private String name;
    private Date date;
    private String sex;
    Thread thread;
    Person personV;

    public SpecialThread(int id2, String thname) {
        this.id2 = id2;
        this.thname = thname;
        thread = new Thread(this,thname);
        thread.start();
    }
    public SpecialThread(String name, String sex, Date date , String thname) {
        this.thname = thname;
        this.name = name;
        this.date = date;
        this.sex = sex;
        thread = new Thread(this,thname);
        thread.start();
    }
    public SpecialThread(int id2, String name, String sex, Date date, String thname) {
        this.id2 = id2;
        this.name = name;
        this.sex = sex;
        this.date = date;
        this.thname = thname;
        thread = new Thread(this,thname);
        thread.start();
    }

    public void run() {
        try {
            //personV = Solution.allPeople.get(id2);
            if(Thread.currentThread().getName().equals("info")) {                    //Запуск задачи с индексом -i
                System.out.println(Solution.allPeople.get(id2).getName() + " " + SexOb(Solution.allPeople.get(id2).getSex()) + " " + DateOb(Solution.allPeople.get(id2).getBirthDate()));
                //System.out.println("Поток " + Thread.currentThread().getName() + " id = " + id2);

            } else if (Thread.currentThread().getName().equals("delete")) {          //Запуск задачи с индексом -d
                //System.out.println("Поток " + Thread.currentThread().getName() + " id = " + id2);
                Solution.allPeople.get(id2).setName(null);
                Solution.allPeople.get(id2).setSex(null);
                Solution.allPeople.get(id2).setBirthDate(null);
                Solution.allPeople.set(id2, Solution.allPeople.get(id2));

                // Введем кого удалили
                Sex Sex2 = Solution.allPeople.get(id2).getSex();
                Date date2 = Solution.allPeople.get(id2).getBirthDate();
                System.out.println("Логически удален чел с индеком: " + id2 + "\n" + Solution.allPeople.get(id2).getName() + " " + Solution.allPeople.get(id2).getSex() + " " + Solution.allPeople.get(id2).getBirthDate());

            } else if(Thread.currentThread().getName().equals("create")) {             //Запуск задачи с индексом -с
                //System.out.println("Поток " + Thread.currentThread().getName() + " " + Thread.currentThread().getId());
                //System.out.println(name + " " + DateOb(date));
                if (sex.equals("м")) {
                    Solution.allPeople.add(Person.createMale(name, date));
                } else {
                    Solution.allPeople.add(Person.createFemale(name, date));
                }
                int idD = Solution.allPeople.size()-1;
                System.out.println(idD);
                //System.out.println(Solution.allPeople.get(idD).getName() + " " + SexOb(Solution.allPeople.get(idD).getSex()) + " " + DateOb(Solution.allPeople.get(idD).getBirthDate()));

            } else if(Thread.currentThread().getName().equals("update")) {             //Запуск задачи с индексом -u
                //System.out.println("Поток " + Thread.currentThread().getName() + " id = " + id2);

                if (id2 <= Solution.allPeople.size()) {
                    if (sex.equals("м")) {
                        Solution.allPeople.set(id2, Person.createMale(name, date));
                    } else {
                        Solution.allPeople.add(id2, Person.createFemale(name, date));
                    }
                } else System.out.println("Такого индекса нет :(");
                // Покажем кого ввели
                System.out.println(Solution.allPeople.get(id2).getName() + " " + SexOb(Solution.allPeople.get(id2).getSex()) + " " + DateOb(Solution.allPeople.get(id2).getBirthDate()));


            } else System.out.println("Введен неизвестный идентификатор потока");

        } catch (IndexOutOfBoundsException e) {
            System.out.println("Такого ID = "+ id2 + " индекса в базе нет");
        }
    }
    public static String SexOb(Sex sex) {
        String sexS = sex.toString();
        if (sexS.equals("MALE")) {
            sexS = "м";
        } else sexS = "ж";
        return sexS;
    }
    public static String DateOb(Date date) {
        SimpleDateFormat dateFormat1 = new SimpleDateFormat("dd-MMM-yyyy", Locale.ENGLISH);
        //String date1 = dateFormat1.format(date);
        return dateFormat1.format(date);
    }
}

