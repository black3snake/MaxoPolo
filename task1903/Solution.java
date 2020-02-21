package com.javarush.task.task19.task1903;

/* 
Адаптация нескольких интерфейсов
*/

import java.util.HashMap;
import java.util.Map;

public class Solution {
    public static Map<String, String> countries = new HashMap<String, String>();
    static {
        countries.put("UA", "Ukraine");
        countries.put("RU", "Russia");
        countries.put("CA", "Canada");
    }

    public static void main(String[] args) {
        IncomeData incomeData = new IncomeData() {  //анонимный класс, в фигурных скобках указано тело класса, который не имеет названия, но реализует интерфейс IncomeData.
            @Override
            public String getCountryCode() {
                return "RU";
            }
            @Override
            public String getCompany() {
                return "JavaRush Ltd.";
            }
            @Override
            public String getContactFirstName() {
                return "Maxim";
            }
            @Override
            public String getContactLastName() {
                return "Polo";
            }
            @Override
            public int getCountryPhoneCode() {
                return 38;
            }
            @Override
            public int getPhoneNumber() {
                int n = 501234567;
                return n;
            }
        };
        Contact contact = new IncomeDataAdapter(incomeData);
        Customer customer = new IncomeDataAdapter(incomeData);

        System.out.println(contact.getName());
        System.out.println(contact.getPhoneNumber());
        System.out.println(customer.getCompanyName());
        System.out.println(customer.getCountryName());

    }

    public static class IncomeDataAdapter implements Customer,Contact {
        private IncomeData data;
        public IncomeDataAdapter(IncomeData data) {
            this.data = data;
        }
        @Override
        public String getCompanyName() {
            return data.getCompany();
        }
        @Override
        public String getCountryName() {
            for(Map.Entry<String,String> pair : countries.entrySet()) {
                if(pair.getKey().equals(data.getCountryCode())) {
                    return pair.getValue();
                }
            }
            return null;
        }
        @Override
        public String getName() {
            return data.getContactLastName() + ", " + data.getContactFirstName();
        }
        @Override
        public String getPhoneNumber() {
            String phone = String.format("%010d", data.getPhoneNumber());
            String result = String.format("%+d(%s)%s-%s-%s", data.getCountryPhoneCode(),phone.substring(0,3),phone.substring(3,6),phone.substring(6,8),phone.substring(8,10));
            return result;
        }
    }
    public static interface IncomeData {
        String getCountryCode();        //For example: UA

        String getCompany();            //For example: JavaRush Ltd.

        String getContactFirstName();   //For example: Ivan

        String getContactLastName();    //For example: Ivanov

        int getCountryPhoneCode();      //For example: 38

        int getPhoneNumber();           //For example: 501234567
    }
    public static interface Customer {
        String getCompanyName();        //For example: JavaRush Ltd.

        String getCountryName();        //For example: Ukraine
    }
    public static interface Contact {
        String getName();               //For example: Ivanov, Ivan

        String getPhoneNumber();        //For example: +38(050)123-45-67
    }
}