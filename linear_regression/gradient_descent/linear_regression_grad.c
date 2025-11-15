#include <stdio.h>

void train(double x[], double y[], int m, double* theta_0, double* theta_1, double alpha, int epochs);
void predict(double x[], double y_pred[], int n, double theta_0, double theta_1);


int main(void){
    double x[] = {1, 2, 3, 4};
    double y[] = {3, 5, 7, 9};
    double theta_0, theta_1; 

    train(x, y, 4, &theta_0, &theta_1, 0.1, 100); 

    double x_test[] = {5, 6}; 
    double y_pred[2]; 
    predict(x_test, y_pred, 2, theta_0, theta_1); 

    printf("\n==== Model Stats ====");
    printf("\nSlope: %lf", theta_1);
    printf("\nIntercept: %lf", theta_0);
    printf("\nRegression Line: y = %lf + %lfx", theta_0, theta_1);

    printf("\n\n==== Testing ====");
    printf("\nPredictions on y=2x+1 line:");
    for(int i = 0; i < 2; i++){
        printf("\n\tx = %lf -> y = %lf", x_test[i], y_pred[i]);
    }
    printf("\n");

    return 0;
}



void train(double x[], double y[], int m, double* theta_0, double* theta_1, double alpha, int epochs){

    // Perform gradient descent over the full training data once per epoch
    for (int epoch = 1; epoch <= epochs; epoch++){
        double grad_0 = 0.0;    // Gradient for theta_0
        double grad_1 = 0.0;    // Gradient for theta_1

        // Compute gradients 
        for (int i = 0; i < m; i++){
            double y_pred = (*theta_0) + (*theta_1) * x[i];
            double error = y_pred - y[i]; 
            grad_0 += error; 
            grad_1 += error * x[i]; 
        }
        grad_0 /= m; 
        grad_1 /=m; 

        // Update parameters 
        *theta_0 -= alpha * grad_0; 
        *theta_1 -= alpha * grad_1; 
    }
}


void predict(double x[], double y_pred[], int m, double theta_0, double theta_1){
    for(int i = 0; i < m; i++){
        y_pred[i] = theta_0 + theta_1 * x[i]; 
    }
}
