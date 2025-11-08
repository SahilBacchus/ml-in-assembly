
int predict(double x[], int n, double weights[]);
int step(double z);




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


