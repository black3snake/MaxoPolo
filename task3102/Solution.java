package com.javarush.task.task31.task3102;

import java.io.IOException;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.LinkedList;
import java.util.List;

/* 
Находим все файлы
*/
public class Solution {
    public static List<String> getFileTree(String root) throws IOException {
        List<String> lllist = new LinkedList<>();
        Files.walkFileTree(Paths.get(root), new FileVisitor<Path>() {
            @Override
            public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) {
                return FileVisitResult.CONTINUE;
            }

            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) {
                lllist.add(file.toAbsolutePath().toString());
                return FileVisitResult.CONTINUE;
            }

            @Override
            public FileVisitResult visitFileFailed(Path file, IOException exc) {
                return FileVisitResult.SKIP_SUBTREE;
            }

            @Override
            public FileVisitResult postVisitDirectory(Path dir, IOException exc) {
                return FileVisitResult.CONTINUE;
            }
        });
        return lllist;

    }

    public static void main(String[] args) throws IOException {

        //Path testFile = Paths.get("F:\\1\\Files\\t1\\art.txt");
        List<String> llist;
        llist = getFileTree("F:\\1");

        for(String str : llist) {
            System.out.println(str);
        }
        System.out.println("Количество файлов в директории : " + llist.size());
    }
}
