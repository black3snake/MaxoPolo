package com.javarush.task.task19.task1905;

import java.util.HashMap;
import java.util.Map;

/* 
Закрепляем адаптер
Адаптировать Customer и Contact к RowItem.
Классом-адаптером является DataAdapter.

Инициализируйте countries перед началом выполнения программы. Соответствие кода страны и названия:
UA Ukraine
RU Russia
CA Canada

Требования:
1. Класс Solution должен содержать public static поле countries типа Map<String, String>.
2. В статическом блоке класса Solution инициализируй поле countries тестовыми данными согласно заданию.
3. Класс Solution должен содержать интерфейс RowItem.
4. Класс Solution должен содержать интерфейс Contact.
5. Класс Solution должен содержать интерфейс Customer.
6. Класс DataAdapter должен реализовывать интерфейс RowItem.
7. Класс DataAdapter должен содержать два приватных поля: customer типа Customer и contact Contact.
8. Класс DataAdapter должен содержать конструктор с параметрами (Customer customer, Contact contact), который инициализирует поля contact и customer.
9. В классе DataAdapter реализуй методы интерфейса RowItem используя подсказки в виде комментариев в интерфейсах.
*/

public class Solution {
    public static Map<String,String> countries = new HashMap<String,String>();
    static {
        countries.put("UA", "Ukraine");
        countries.put("RU", "Russia");
        countries.put("CA", "Canada");
    }
    public static void main(String[] args) {
        Customer customer = new Customer() {
            @Override
            public String getCompanyName() {
                return "JavaRush Ltd.";
            }
            @Override
            public String getCountryName() {
                return "Russia";
            }
        };
        Contact contact = new Contact() {
            @Override
            public String getName() {
                return "Ivanov, Ivan";
            }
            @Override
            public String getPhoneNumber() {
                return "+380(50)123-4567";
            }
        };
        RowItem rowItem = new DataAdapter(customer,contact);
        System.out.println(rowItem.getCountryCode());
        System.out.println(rowItem.getCompany());
        System.out.println(rowItem.getContactFirstName());
        System.out.println(rowItem.getContactLastName());
        System.out.println(rowItem.getDialString());
    }

    public static class DataAdapter implements RowItem{
        private Customer customer;
        private Contact contact;
        public DataAdapter(Customer customer, Contact contact) {
            this.customer = customer;
            this.contact = contact;
        }
        @Override
        public String getCountryCode() {
            for (Map.Entry<String,String> pair : countries.entrySet()) {
                if(pair.getValue().equals(customer.getCountryName())) {
                    return pair.getKey();
                }
            }
            return null;
        }
        @Override
        public String getCompany() {
            return this.customer.getCompanyName();
        }
        @Override
        public String getContactFirstName() {
            return this.contact.getName().replaceAll("[a-zA-Z].+\\,\\s?", "");
        }
        @Override
        public String getContactLastName() {
            return this.contact.getName().replaceAll("\\,\\s[a-zA-Z].+$", "");
        }
        @Override
        public String getDialString() {
            return "callto://+" + this.contact.getPhoneNumber().replaceAll("\\D","");
        }
    }

    public static interface RowItem {
        String getCountryCode();        //For example: UA
        String getCompany();            //For example: JavaRush Ltd.
        String getContactFirstName();   //For example: Ivan
        String getContactLastName();    //For example: Ivanov
        String getDialString();         //For example: callto://+380501234567
    }
    public static interface Customer {
        String getCompanyName();        //For example: JavaRush Ltd.
        String getCountryName();        //For example: Ukraine
    }
    public static interface Contact {
        String getName();               //For example: Ivanov, Ivan
        String getPhoneNumber();        //For example: +38(050)123-45-67 or +3(805)0123-4567 or +380(50)123-4567 or ...
    }
}