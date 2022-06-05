package com.javarush.task.task20.task2021;

import java.io.*;

/*
Сериализация под запретом
Что если вы создали класс, чей суперкласс сериализуемый,
но при этом вы не хотите чтобы ваш класс был сериализуемым?
Вы не можете "разреализовать" интерфейс, поэтому если суперкласс
реализует Serializable, то и созданный вами новый класс также
будет реализовать его. Чтобы остановить автоматическую сериализацию вы
можете применить private методы для создания исключительной
ситуации NotSerializableException.
*/
public class Solution implements Serializable {
    public static class SubSolution extends Solution {

    private void writeObject(ObjectOutputStream out) throws IOException {
        throw new NotSerializableException("Not Todey");
    }
    private void readObject(ObjectInputStream in) throws IOException {
        throw new NotSerializableException("Not Todey");
    }

    }

    public static void main(String[] args) {

    }
}
