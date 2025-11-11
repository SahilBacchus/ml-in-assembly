#include <stdio.h>

#define MAX_FEATURES 2

int predict(double x[], int n, double weights[]);
int step(double z);
void train(double X[][MAX_FEATURES], double Y[], int num_samples, int num_features, double weights[], double eta, int epochs);

int main(void){
    double X[][MAX_FEATURES] = {{0, 0}, {0, 1}, {1, 0}, {1, 1}};
    double y[] = {0, 0, 0, 1};
    double weights[MAX_FEATURES + 1]; 
    int y_pred; 

    train(X, y, 4, 2, weights, 0.1, 5); 

    printf("\n==== Model Stats ====");
    printf("\nWeights: ["); 
    for (int i = 0; i < MAX_FEATURES + 1; i++){
        printf("%lf, ", weights[i]); 
    }
    printf("]"); 

    printf("\n\n==== Testing ====");
    printf("\nPredictions on AND Gate:");
    for(int i = 0; i < 4; i++){
        y_pred = predict(X[i], 2, weights); 
        printf("\n\tx = [%lf, %lf] -> y = %d", X[i][0], X[i][1], y_pred);
    }
    printf("\n");

    return 0; 
}


void train(double X[][MAX_FEATURES], double Y[], int num_samples, int num_features, double weights[], double eta, int epochs){
    // Intialize weights to zeroes
    for (int i = 0; i < num_features + 1; i++){
        weights[i] = 0.0; 
    }

    for (int epoch = 0; epoch < epochs; epoch++){

        // Loop through each vector (X[i]) in the dataset
        for (int i = 0; i < num_samples; i++){
            int y_pred = predict(X[i], num_features, weights); 
            int error = Y[i] - y_pred; 

            // Update bias
            weights[0] += eta * error; 

            // Apply the perceptron update rule for the other weights
            for (int j = 0; j < num_features; j++){
                weights[j + 1] += eta * error * X[i][j]; 
            }
        }
    }
}


int predict(double x[], int n, double weights[]){
    double z = weights[0]; // bias
    for (int i = 0; i < n; i++){
        z += weights[i + 1] * x[i];
    }

    return step(z);
}


int step(double z){
    return z >= 0.0 ? 1 : 0; 
}


