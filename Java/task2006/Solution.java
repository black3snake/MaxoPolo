package com.javarush.task.task20.task2006;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/* 
Как сериализовать?
Переопределил toString , для понимания конструкции String... assets
String... assets означает любое количество объктов класса String,
а внутри процедуры они выглядят как элементы массива String[]
*/
public class Solution {
    public static class Human implements Serializable {
        public String name;
        public List<String> assets = new ArrayList<>();

        public Human() {
        }

        public Human(String name, String... assets) {
            this.name = name;
            if (assets != null) {
                this.assets.addAll(Arrays.asList(assets));
            }
        }
        @Override
        public String toString() {
            return "Human{" + "name='" + name + '\'' + ", " + assets.toString() + '}';
        }
    }

    public static void main(String[] args) {

        Human ivanov = new Human("Ivanov", "test1","test2","test3");
        System.out.println(ivanov.toString());
    }


}
