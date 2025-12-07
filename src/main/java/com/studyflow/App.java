package com.studyflow;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.util.Objects;

/**
 * Главный класс приложения StudyFlow.
 * Точка входа в JavaFX приложение.
 */
public class App extends Application {
    
    @Override
    public void start(Stage primaryStage) {
        try {
            // Загружаем FXML файл главного окна
            Parent root = FXMLLoader.load(
                Objects.requireNonNull(getClass().getResource("/fxml/main.fxml"))
            );
            
            // Настраиваем главное окно
            primaryStage.setTitle("StudyFlow - Intelligent Student Planner");
            primaryStage.setScene(new Scene(root, 1200, 800));
            primaryStage.setMinWidth(900);
            primaryStage.setMinHeight(600);
            
            // Показываем окно
            primaryStage.show();
            
        } catch (Exception e) {
            System.err.println("Error loading application: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Точка входа в приложение.
     * @param args аргументы командной строки
     */
    public static void main(String[] args) {
        launch(args);
    }
}
