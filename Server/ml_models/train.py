#%%
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint

# Configuration
data_root = r"C:\Programming\ml_models\Fall_UP_Dataset\UP_Fall_Detection_Dataset"
window_size = 100  # Assuming 10Hz sampling rate, 10 seconds = 100 samples
subjects = ['Subject_01', 'Subject_02', 'Subject_03', 'Subject_04']
activities = [f'A{i:02d}' for i in range(1, 12)]
trials = ['T01', 'T02', 'T03']

# Based on the activity table:
# Activities 1-5 and 9-10 involve falling - label 1
# Activities 6-8 and 11 are non-falling activities - label 0
falling_activities = ['A01', 'A02', 'A03', 'A04', 'A05', 'A09', 'A10']
non_falling_activities = ['A06', 'A07', 'A08', 'A11']

def load_and_process_data(data_root, subjects, activities, trials):
    """
    Load and process data from the file structure.
    Returns X (features) and y (labels) for model training.
    """
    X_segments = []
    y_labels = []
    
    for subject in subjects:
        for activity in activities:
            is_falling = 1 if activity in falling_activities else 0
            
            for trial in trials:
                # Construct file path
                file_name = f"S{subject[-2:]}_A{activity[-2:]}_T{trial[-2:]}.csv"
                file_path = os.path.join(data_root, subject, activity, file_name)
                
                try:
                    # Load data
                    df = pd.read_csv(file_path)
                    
                    # Extract acceleration data
                    acc_data = df[['PCKT_ACC_X', 'PCKT_ACC_Y', 'PCKT_ACC_Z']].values
                    
                    # Create segments (sliding window approach)
                    for i in range(0, len(acc_data) - window_size + 1, window_size // 2):  # 50% overlap
                        segment = acc_data[i:i + window_size]
                        if len(segment) == window_size:  # Ensure segment is complete
                            X_segments.append(segment)
                            y_labels.append(is_falling)
                    
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")
    
    return np.array(X_segments), np.array(y_labels)

def build_lstm_model(input_shape):
    """
    Build and compile the LSTM model
    """
    model = Sequential([
        LSTM(64, return_sequences=True, input_shape=input_shape),
        Dropout(0.2),
        LSTM(32),
        Dropout(0.2),
        Dense(16, activation='relu'),
        Dense(1, activation='sigmoid')  # Binary classification
    ])
    
    model.compile(
        optimizer='adam',
        loss='binary_crossentropy',
        metrics=['accuracy']
    )
    
    return model

def preprocess_data(X, y):
    """
    Preprocess the data - normalize and split into train/validation/test sets
    """
    # Reshape for scaling
    X_reshaped = X.reshape(-1, X.shape[2])
    
    # Scale the data
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X_reshaped)
    
    # Reshape back
    X_preprocessed = X_scaled.reshape(X.shape)
    
    # Split into train, validation, and test sets
    X_train_val, X_test, y_train_val, y_test = train_test_split(
        X_preprocessed, y, test_size=0.2, random_state=42, stratify=y
    )

 
    X_train, X_val, y_train, y_val = train_test_split(
        X_train_val, y_train_val, test_size=0.25, random_state=42, stratify=y_train_val
    )
    
    return X_train, X_val, X_test, y_train, y_val, y_test, scaler

def train_model(model, X_train, y_train, X_val, y_val, epochs=50, batch_size=32):
    """
    Train the model with early stopping and model checkpointing
    """
    callbacks = [
        EarlyStopping(monitor='val_loss', patience=10, restore_best_weights=True),
        ModelCheckpoint('best_fall_detection_model.h5', monitor='val_accuracy', save_best_only=True)
    ]
    
    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=epochs,
        batch_size=batch_size,
        callbacks=callbacks
    )
    
    return model, history

def evaluate_model(model, X_test, y_test):
    """
    Evaluate the model on test data
    """
    test_loss, test_accuracy = model.evaluate(X_test, y_test)
    print(f"Test Accuracy: {test_accuracy:.4f}")
    print(f"Test Loss: {test_loss:.4f}")
    
    # Make predictions

    y_pred = (model.predict(X_test) > 0.5).astype(int).flatten()
    
    # Calculate confusion matrix
    from sklearn.metrics import confusion_matrix, classification_report
    cm = confusion_matrix(y_test, y_pred)
    
    # Print classification report
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=['Non-Fall', 'Fall']))
    
    return cm, y_pred

def visualize_results(history, cm):
    """
    Visualize training history and confusion matrix
    """
    # Plot training & validation accuracy and loss
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))
    
    # Accuracy
    ax1.plot(history.history['accuracy'], label='Training Accuracy')
    ax1.plot(history.history['val_accuracy'], label='Validation Accuracy')
    ax1.set_title('Model Accuracy')
    ax1.set_xlabel('Epoch')
    ax1.set_ylabel('Accuracy')
    ax1.legend()
    
    # Loss
    ax2.plot(history.history['loss'], label='Training Loss')
    ax2.plot(history.history['val_loss'], label='Validation Loss')
    ax2.set_title('Model Loss')
    ax2.set_xlabel('Epoch')
    ax2.set_ylabel('Loss')
    ax2.legend()
    
    plt.tight_layout()
    plt.savefig('training_history.png')


def main():
    # Load and process data
    print("Loading and processing data...")
    X, y = load_and_process_data(data_root, subjects, activities, trials)
    
    # Check data distribution
    print(f"Data shape: {X.shape}, Labels shape: {y.shape}")
    print(f"Class distribution: {np.bincount(y)}")
    
    # Preprocess data
    print("Preprocessing data...")
    X_train, X_val, X_test, y_train, y_val, y_test, scaler = preprocess_data(X, y)

    print(X_test[:5])
    # Build model
    print("Building LSTM model...")
    input_shape = (X_train.shape[1], X_train.shape[2])  # (time_steps, features)
    model = build_lstm_model(input_shape)
    model.summary()
    
    # Train model
    print("Training model...")
    trained_model, history = train_model(model, X_train, y_train, X_val, y_val)
    
    # Evaluate model
    print("Evaluating model...")
    cm, y_pred = evaluate_model(trained_model, X_test, y_test)
    
    # Visualize results
    print("Visualizing results...")
    visualize_results(history, cm)
    
    print("Done!")

if __name__ == "__main__":
    main()
# %%
