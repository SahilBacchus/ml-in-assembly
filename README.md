# Machine Learning in Assembly

This project explores how core machine learning algorithms work under the hood by implementing them at the lowest level in RISC-V assembly. By stripping away all library abstractions, we aim to build a deep mathematical intuition for how algorithms like linear regresion, gradient descent, and perceptron operate. 

- **Jupyter Notebooks:** Provide high level  code implmentation, testing on real world data and the math behind these various algorithms 

- **C files:** Contains a lower level simplified code implementation, serving as a stepping stone for assembly translation

- **Assembly files:** Implements a simplified version of these algorithsm directly in RISC-V assembly

---


### 📂 Project Structure

```bash
│
├───activation_functions
│   ├───ReLU
│   ├───sigmoid
│   ├───step
│   └───tanh
├───linear_regression
│   ├───gradient_descent
│   └───least_squares
└───perceptron
```


### 🚀 Getting Started 

#### Clone the repository 

```bash
git clone https://github.com/SahilBacchus/ml-in-assembly.git
cd ml-in-assembly
```

#### Compile and Run the C files

For example if you wanted to run the linear regression using gradient descent once you are in the folder you would run the following: 

```bash
gcc -o linear_regression_grad.exe linear_regression_grad.c
./linear_regression_grad.exe
```

#### Running Assembly Code in RARS (v 1.6)

For this you are going to need RARS, if you don't have it you can download it [here](https://github.com/TheThirdOne/rars/releases/tag/v1.6) (the file rars1_6.jar is the executable).

1) Open the .asm file you want to run 
2) Click the assemble the current file button (the srewdriver and wrench icon)
3) Cick the run program button (the green play icon)
4) You can observe the output in the "Run I\O" tab at the bottom 