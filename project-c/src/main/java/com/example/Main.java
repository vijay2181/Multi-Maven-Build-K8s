package com.example;

public class Main {
    public static void main(String[] args) {
        System.out.println("╔═══════════════════════════════════════╗");
        System.out.println("║         PROJECT C - K3S JENKINS       ║");
        System.out.println("╚═══════════════════════════════════════╝");
        System.out.println("Environment: " + System.getProperty("build.env", "unknown"));
        System.out.println("Branch: " + System.getProperty("build.branch", "unknown"));
        System.out.println("Build: #" + System.getProperty("build.number", "0"));
        System.out.println("Hello from Project C!");
    }
}
