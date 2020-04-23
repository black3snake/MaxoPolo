package com.javarush.task.task20.task2002;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/* 
Читаем и пишем в файл: JavaRush
*/
public class Solution {
    public static void main(String[] args) {
        //you can find your_file_name.tmp in your TMP directory or adjust outputStream/inputStream according to your file's actual location
        //вы можете найти your_file_name.tmp в папке TMP или исправьте outputStream/inputStream в соответствии с путем к вашему реальному файлу
        try {
            File yourFile = File.createTempFile("date2", null);
            OutputStream outputStream = new FileOutputStream(yourFile);
            InputStream inputStream = new FileInputStream(yourFile);
            SimpleDateFormat df = new SimpleDateFormat("dd-MM-yyyy", Locale.ENGLISH);

            JavaRush javaRush = new JavaRush();
            //initialize users field for the javaRush object here - инициализируйте поле users для объекта javaRush тут
            List<User> Ar = new ArrayList<>();
            // Собственный конструктор
            Ar.add(new User("Иван", "Семенов", df.parse("11-06-1999"), true, User.Country.RUSSIA));
            Ar.add(new User("Сара", "Иванова", df.parse("2-02-1943"), false, User.Country.UKRAINE));
            Ar.add(new User("Надя", "Хренова", df.parse("9-07-1961"), false, User.Country.OTHER));
            // Конструктор по умолчанию
            User user_1 = new User();
            user_1.setFirstName("Иван2");
            user_1.setLastName("Семенов");
            user_1.setBirthDate(df.parse("11-06-1956"));
            user_1.setMale(true);
            user_1.setCountry(User.Country.RUSSIA);
            Ar.add(user_1);

            javaRush.users = Ar;
            javaRush.save(outputStream);
            outputStream.flush();

            JavaRush loadedObject = new JavaRush();
            loadedObject.load(inputStream);
            //here check that the javaRush object is equal to the loadedObject object - проверьте тут, что javaRush и loadedObject равны

            outputStream.close();
            inputStream.close();

            if(javaRush.equals(loadedObject)) {
                System.out.println("Объекты равны");
            }
            //Удалить временный файл
            //yourFile.deleteOnExit();

        } catch (IOException e) {
            //e.printStackTrace();
            System.out.println("Oops, something is wrong with my file");
        } catch (Exception e) {
            //e.printStackTrace();
            System.out.println("Oops, something is wrong with the save/load method");
        }
    }

    public static class JavaRush {
        public List<User> users = new ArrayList<>();
        //SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy", Locale.ENGLISH);
        Date date = new Date();

        public void save(OutputStream outputStream) throws Exception {
            //implement this method - реализуйте этот метод
            StringBuilder sb = new StringBuilder();
            if(users.size()>0) {
                for (int i = 0; i < users.size() ; i++) {
                    Long ms = users.get(i).getBirthDate().getTime();
                    sb.append(users.get(i).getFirstName()).append("|");
                    sb.append(users.get(i).getLastName()).append("|");
                    //sb.append(dateFormat.format(users.get(i).getBirthDate().getTime())).append("|");
                    sb.append(ms).append("|");
                    sb.append(users.get(i).isMale()).append("|");
                    sb.append(users.get(i).getCountry()).append(System.lineSeparator());

                    outputStream.write(sb.toString().getBytes());
                    sb.delete(0,sb.length());
                }

            }
        }

        public void load(InputStream inputStream) throws Exception {
            //implement this method - реализуйте этот метод
            BufferedReader buffR = new BufferedReader(new InputStreamReader(inputStream, "windows-1251"));
            while (buffR.ready()) {
                String Ttroka = buffR.readLine();
                String[] Tarray = Ttroka.split("\\|");
                if(Tarray.length > 0)
                //users.add(new User(Tarray[0], Tarray[1], dateFormat.parse(Tarray[2]), Boolean.parseBoolean(Tarray[3]), User.Country.valueOf(Tarray[4])));
                    try {
                       users.add(new User(Tarray[0], Tarray[1], new Date(Long.parseLong(Tarray[2])), Boolean.parseBoolean(Tarray[3]), User.Country.valueOf(Tarray[4])));
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
            }

        buffR.close();
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;

            JavaRush javaRush = (JavaRush) o;

            return users != null ? users.equals(javaRush.users) : javaRush.users == null;

        }

        @Override
        public int hashCode() {
            return users != null ? users.hashCode() : 0;
        }
    }
}
