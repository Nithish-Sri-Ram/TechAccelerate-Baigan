import json
import numpy as np
import time
import asyncio
import logging
from tensorflow.keras.models import load_model
from sklearn.preprocessing import StandardScaler
import pickle

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Processing constants
PROCESSING_RATE = 10  # 10Hz
WINDOW_SIZE = 100

class FallDetector:
    def __init__(self, model_path='C:/Programming/TechAccelerate-Baigan/Server/ml_models/best_fall_detection_model.h5', scaler_path=r'C:\Programming\TechAccelerate-Baigan\Server\ml_models\scaler.pkl'):
        self.model = load_model(model_path)
        
        try:
            with open(scaler_path, 'rb') as f:
                self.scaler = pickle.load(f)
        except FileNotFoundError:
            # Create default scaler
            self.scaler = StandardScaler()
            synthetic_data = np.random.uniform(-20, 20, (1000, 3))
            self.scaler.fit(synthetic_data)
            with open(scaler_path, 'wb') as f:
                pickle.dump(self.scaler, f)
        
        self.latest_data = None
        self.running = False
    
    def process_data(self, json_data):
        # Parse JSON if needed
        data = json.loads(json_data) if isinstance(json_data, str) else json_data
        
        # Extract accelerometer values
        acc_x = data['accelerometer']['x']
        acc_y = data['accelerometer']['y'] 
        acc_z = data['accelerometer']['z']
        
        # Create sample with repeated values to match window size
        sample = np.array([[acc_x, acc_y, acc_z]] * WINDOW_SIZE)
        
        # Preprocess
        sample_scaled = self.scaler.transform(sample)
        sample_processed = sample_scaled.reshape(1, WINDOW_SIZE, 3)
        
        # Make prediction
        prediction = self.model.predict(sample_processed, verbose=0)[0][0]
        
        return {
            "is_fall": bool(prediction > 0.5),
            "confidence": float(prediction),
            "timestamp": data.get("timestamp", time.time())
        }
    
    def update_data(self, data):
        self.latest_data = data
    
    async def start_processing(self, callback):
        self.running = True
        interval = 1.0 / PROCESSING_RATE
        
        while self.running:
            start_time = time.time()
            
            if self.latest_data:
                try:
                    result = self.process_data(self.latest_data)
                    callback(result)
                except Exception as e:
                    logger.error(f"Prediction error: {str(e)}")
            
            # Sleep to maintain fixed rate
            elapsed = time.time() - start_time
            await asyncio.sleep(max(0, interval - elapsed))
    
    def stop_processing(self):
        self.running = False