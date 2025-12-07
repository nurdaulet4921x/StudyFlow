package com.studyflow.controllers;

import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;

/**
 * Контроллер для главного окна приложения.
 * Управляет взаимодействием пользователя с интерфейсом.
 */
public class MainController {
    
    @FXML
    private Label welcomeLabel;
    
    @FXML
    private VBox mainContent;
    
    /**
     * Инициализация контроллера.
     * Вызывается автоматически после загрузки FXML.
     */
    @FXML
    private void initialize() {
        // Устанавливаем приветственное сообщение
        welcomeLabel.setText("Добро пожаловать в StudyFlow!");
        
        // Здесь будет дополнительная инициализация
        // Например, загрузка данных из базы
    }
    
    /**
     * Обработчик нажатия кнопки Dashboard.
     */
    @FXML
    private void handleDashboardButton() {
        welcomeLabel.setText("Панель управления");
        // Здесь будет логика переключения на dashboard
    }
    
    /**
     * Обработчик нажатия кнопки Schedule.
     */
    @FXML
    private void handleScheduleButton() {
        welcomeLabel.setText("Расписание занятий");
        // Здесь будет логика переключения на расписание
    }
    
    /**
     * Обработчик нажатия кнопки Tasks.
     */
    @FXML
    private void handleTasksButton() {
        welcomeLabel.setText("Учебные задачи");
        // Здесь будет логика переключения на задачи
    }
    
    /**
     * Обработчик нажатия кнопки Notes.
     */
    @FXML
    private void handleNotesButton() {
        welcomeLabel.setText("Заметки и конспекты");
        // Здесь будет логика переключения на заметки
    }
}
