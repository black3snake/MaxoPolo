package com.javarush.task.task18.task1825;

import java.io.*;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/* 
Собираем файл
*/

public class Solution {
    public static void main(String[] args) {
        ArrayList<FileN> files = new ArrayList<>();
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        FileOutputStream out;
        FileInputStream in;
        Pattern p_ext = Pattern.compile("[0-9&&[^a-zA-Z]&&[^\\\\]]?[0-9]+$");
        Pattern p_str = Pattern.compile(".+[a-z&&[^0-9]]");
        //Pattern p_org = Pattern.compile("^.+?\\.+[a-z]{3}");

        try {
            while (true) {
                String fileN = reader.readLine();
                //if (fileN == null || fileN.isEmpty() || fileN.equals("end")) {
                if (fileN.equals("end")) {
                    break;
                }
                Matcher m_ext = p_ext.matcher(fileN);
                Matcher m_str = p_str.matcher(fileN);

                while (m_str.find() && m_ext.find()) {
                    //System.out.println(m_str.group() + " - " + m_ext.group());
                    files.add(new FileN(m_str.group(), Integer.parseInt(m_ext.group())));
                }
            }
            //System.out.println(files.toString());
            reader.close();
            FileNameZ fz = new FileNameZ();
            files.sort(fz);

            System.out.println("Sorted: ");
            for (FileN h: files) {
                System.out.println(h);
            }

            String PathF = files.get(0).path.substring(0, files.get(0).path.lastIndexOf(".part"));
            out = new FileOutputStream(PathF, true);
            StringBuffer sb = new StringBuffer();

            for (int i = 0; i < files.size() ; i++) {
                sb.append(files.get(i).path);
                sb.append(files.get(i).chislo);
                in = new FileInputStream(sb.toString());
                sb.delete(0, sb.length());
                while (in.available() > 0) {
                    byte[] buffer = new byte[in.available()];
                    int j = in.read(buffer);
                    out.write(buffer,0,j);
                }
                in.close();
            }
            out.close();
        } catch (IOException e) {
            System.out.println("Ошибка ввода вывода " + e.getMessage());
        }
    }
}
    class FileN {
        String path;
        int chislo;

        public FileN(String path, int chislo) {
            this.path = path;
            this.chislo = chislo;
        }
        @Override
        public String toString() {
            final StringBuffer sb = new StringBuffer("FileN {");
            sb.append("path=").append(path);
            sb.append(", chislo=").append(chislo);
            sb.append('}');
            return sb.toString();
        }
    }

    class FileNameZ implements Comparator<FileN> {
        @Override
        public int compare(FileN F1, FileN F2) {
            if (F1.chislo == F2.chislo) {
                return 0;
            }
            if (F1.chislo > F2.chislo) {
                return 1;
            } else {
                return -1;
            }
        }
    }

