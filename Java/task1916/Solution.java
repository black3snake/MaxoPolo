package com.javarush.task.task19.task1916;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

/* 
Отслеживаем изменения
Финальное решение :-) Валя приняла. Зашло идеально.
*/

public class Solution {
    public static List<LineItem> lines = new ArrayList<LineItem>();

    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        BufferedReader buffRF1 = new BufferedReader(new FileReader(reader.readLine()));
        BufferedReader buffRF2 = new BufferedReader(new FileReader(reader.readLine()));
        reader.close();
        List<String> listF1 = new ArrayList<>();
        List<String> listF2 = new ArrayList<>();
        String F1, F2;
        while (buffRF1.ready() || buffRF2.ready()) {
            if ((F1 = buffRF1.readLine()) != null) listF1.add(F1);
            if ((F2 = buffRF2.readLine()) != null) listF2.add(F2);
        }
        for (int i = 0; i < listF1.size(); i++) {
            try {
                for (int j = 0; j < listF2.size(); j++) {

                    if (listF1.get(i).equals(listF2.get(j))) {
                        lines.add(new LineItem(Type.SAME, listF1.get(i)));
                        listF1.remove(0);
                        listF2.remove(0);
                    } else if (listF1.get(i + 1).equals(listF2.get(j))) {
                        lines.add(new LineItem(Type.REMOVED, listF1.get(i)));
                        listF1.remove(0);
                    } else if (listF1.get(i).equals(listF2.get(j + 1))) {
                        lines.add(new LineItem(Type.ADDED, listF2.get(j)));
                        listF2.remove(0);
                    }
                    j--;
                }
                if (!listF1.get(i).isEmpty()) {
                    lines.add(new LineItem(Type.REMOVED, listF1.get(i)));
                    listF1.remove(0);
                }
            } catch (IndexOutOfBoundsException e) {
                lines.add(new LineItem(Type.ADDED, listF2.get(0)));
                listF2.remove(0);
            }
        }

        for (int i = 0; i < lines.size(); i++) {
            System.out.println(lines.get(i).type + " " + lines.get(i).line);

        }
        buffRF1.close();
        buffRF2.close();
    }

    public static enum Type {
        ADDED,        //добавлена новая строка
        REMOVED,      //удалена строка
        SAME          //без изменений
    }

    public static class LineItem {
        public Type type;
        public String line;

        public LineItem(Type type, String line) {
            this.type = type;
            this.line = line;
        }
    }
}
