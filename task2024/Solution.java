package com.javarush.task.task20.task2024;

import java.io.Serializable;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

/* 
Знакомство с графами
*/
public class Solution implements Serializable {
    int node;
    List<Solution> edges = new LinkedList<>();

    public static class One extends Solution {
        One(int node) {
            this.node = node;
        }
    }
    public static class Two extends Solution {
        Two(int node) {
            this.node = node;
        }
    }
    public static class Three extends Solution {
        Three(int node) {
            this.node = node;
        }
    }

    public static void main(String[] args) {
        Solution sol = new Solution();
        sol.edges.add(new One(1));
        sol.edges.add(new Two(2));
        sol.edges.add(new Three(3));

        System.out.println( Arrays.asList(sol.edges));
    }
}
