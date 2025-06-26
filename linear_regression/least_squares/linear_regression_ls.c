#include <stdio.h>

void fit(double x[], double y[], int n, double* beta_0, double* beta_1);
void predict(double x[], double y_pred[], int n, double beta_0, double beta_1);


int main(void){
    double x[] = {1, 2, 3, 4};
    double y[] = {3, 5, 7, 9};
    double beta_0, beta_1; 

    fit(x, y, 4, &beta_0, &beta_1); 

    double x_test[] = {5, 6}; 
    double y_pred[2]; 
    predict(x_test, y_pred, 2, beta_0, beta_1); 

    printf("\n==== Model Stats ====");
    printf("\nSlope: %lf", beta_1);
    printf("\nIntercept: %lf", beta_0);
    printf("\nRegression Line: y = %lf + %lfx", beta_0, beta_1);

    printf("\n\n==== Testing ====");
    printf("\nPredictions on y=2x+1 line:");
    for(int i = 0; i < 2; i++){
        printf("\n\tx = %lf -> y = %lf", x_test[i], y_pred[i]);
    }
    printf("\n");

    return 0;
}



void fit(double x[], double y[], int n, double* beta_0, double* beta_1){
    double x_sum = 0;
    double y_sum = 0; 
    double xy_sum = 0; 
    double x_squared_sum = 0;  

    for(int i = 0; i < n; i++){
        x_sum += x[i];
        y_sum += y[i];
        xy_sum += x[i] * y[i]; 
        x_squared_sum += x[i] * x[i]; 
    }

    double x_mean = x_sum / n; 
    double y_mean = y_sum / n; 

    // Calculate slope (beta_1)
    double beta_1_numerator = xy_sum - n * x_mean * y_mean; 
    double beta_1_denominator = x_squared_sum - n * x_mean * x_mean; 
    *beta_1 = beta_1_numerator / beta_1_denominator; 

    // Calculate intercept (beta_0)
    *beta_0 = y_mean - (*beta_1) * x_mean; 
}


void predict(double x[], double y_pred[], int n, double beta_0, double beta_1){
    for(int i = 0; i < n; i++){
        y_pred[i] = beta_0 + beta_1 * x[i]; 
    }
}
