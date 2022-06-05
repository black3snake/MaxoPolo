package com.javarush.task.task20.task2011;

import java.io.*;

/*
Externalizable для апартаментов
Дописанный для понимания общей картины.
*/
public class Solution {

    public static class Apartment implements Externalizable {

        private String address;
        private int year;

        /**
         * Mandatory public no-arg constructor.
         */
        public Apartment() {
            super();
        }

        public Apartment(String addr, int y) {
            address = addr;
            year = y;
        }

        /**
         * Prints out the fields used for testing!
         */
        public String toString() {
            return ("Address: " + address + "\n" + "Year: " + year);
        }

        @Override
        public void writeExternal(ObjectOutput out) throws IOException {
            out.writeObject(address);
            out.writeInt(year);
        }

        @Override
        public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException {
            address = (String) in.readObject();
            year = in.readInt();
        }
    }

    public static void main(String[] args) {
            Apartment apar = new Apartment("Kolhoznaya 15", 1998);
            System.out.println(apar.toString());

            try ( FileOutputStream fs = new FileOutputStream(new File("f://1//externali.txt"));
                  ObjectOutputStream oos = new ObjectOutputStream(fs) ) {

                oos.writeObject(apar);
                oos.flush();

            } catch (IOException e) {
                e.printStackTrace();
            }
            apar = null;
            try (FileInputStream fis = new FileInputStream(new File("f://1//externali.txt"));
                  ObjectInputStream ois = new ObjectInputStream(fis)) {
                Apartment aparRes = (Apartment) ois.readObject();
                System.out.println("----------- Надутый ------------\r\n");
                System.out.println(aparRes.toString());

            }catch (IOException | ClassNotFoundException e) {
                e.printStackTrace();
            }

    }
}
