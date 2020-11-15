package com.company;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.FileWriter;

public class Main {

    public static void main(String[] args) {
        //convolutional layer filters and biases
        float[][][][] input = readArr4d("00");
        float[][][][] filters1 = readArr4d("01");
        float[][][][] biases1 = readArr4d("02");
        float[][][][] filters2 = readArr4d("11");
        float[][][][] biases2 = readArr4d("12");
        float[][][][] filters3 = readArr4d("21");
        float[][][][] biases3 = readArr4d("22");

        //last layer weights and biases
        float[][] weights = readArr2d("0", 1);
        float[] biases = readArr1d("1", 2);
        float[][] testResults = readArr2d("2", 3);



        float[][][][] convRes0 = convolve(input, filters1, biases1);
        float[][][][] reLURes0 = reLUAndAddBias(convRes0, biases1);
        float[][][][] maxPoolRes0 = maxPool(reLURes0);
        float[][][][] convRes1 = convolve(input, filters2, biases2);
        float[][][][] reLURes1 = reLUAndAddBias(convRes1, biases2);
        float[][][][] maxPoolRes1 = maxPool(reLURes1);
        float[][][][] convRes2 = convolve(input, filters3, biases3);
        float[][][][] reLURes2 = reLUAndAddBias(convRes2, biases3);
        float[][][][] maxPoolRes2 = maxPool(reLURes2);

        float[][] mergeRes = mergeAndFlatten(maxPoolRes0, maxPoolRes1, maxPoolRes2);

        float[][] matMulRes = matMulAndBias(mergeRes, weights, biases);
        float[][] softMaxRes = softMax(matMulRes);

        int total = 0;
        int i, j, k, l;

        // Check the result
        i = 1031; j = 2; k = 1; l = 1;
        for (int ii = 0; ii < i; ii++) {
            for (int jj = 0; jj < j; jj++) {
                for (int kk = 0; kk < k; kk++) {
                    for (int ll = 0; ll < l; ll++) {
                        if ((int)(softMaxRes[ii][jj]*10000) != (int)(testResults[ii][jj]*10000)){
                            total++;
                            System.out.println("wrong calculation!!!");
                            System.out.printf("a: %f b: %f total:%d\n", softMaxRes[ii][jj], testResults[ii][jj], total);
                        }
                    }
                }
            }
        }
    }

    private static float[][] mergeAndFlatten(float[][][][] maxPoolRes0, float[][][][] maxPoolRes1, float[][][][] maxPoolRes2) {
        float[][] output = new float[maxPoolRes0.length][maxPoolRes0[0].length*3];

        for (int i = 0; i < maxPoolRes0.length; i++) {
            for (int h = 0; h < 3; h++) {
                for (int j = 0; j < maxPoolRes0[0].length; j++){
                    if (h == 0) {
                        output[i][j] = maxPoolRes0[i][j][0][0];
                    }else if (h == 1) {
                        output[i][100 + j] = maxPoolRes1[i][j][0][0];
                    }else if (h == 2) {
                        output[i][200 + j] = maxPoolRes2[i][j][0][0];
                    }
                }
            }
        }

        return output;
    }

    private static float[][] softMax(float[][] matMulRes) {
        float[][] output = new float[matMulRes.length][matMulRes[0].length];
        //number of classes for classification
        float[] tempValues = new float[matMulRes[0].length];

        for (int i = 0; i < matMulRes.length; i++) {
            float sum = 0;
            for (int j = 0; j < matMulRes[0].length; j++) {

                tempValues[j] = (float) Math.exp(matMulRes[i][j]);
                sum += tempValues[j];
            }
            for (int j = 0; j < matMulRes[0].length; j++) {
                output[i][j] = tempValues[j]/sum;
            }
        }

        return output;
    }

    private static float[][] matMulAndBias(float[][] arr0, float[][] arr1, float[] bias) {
        float[][] output = new float[arr0.length][arr1[0].length];

        for (int i = 0; i < arr0.length; i++) {
            for (int j = 0; j < arr1[0].length; j++) {
                float tmp = 0;
                for (int k = 0; k < arr0[0].length; k++) {
                    tmp += arr0[i][k] * arr1[k][j];
                }
                output[i][j] = tmp + bias[j];
            }
        }

        return output;
    }

    private static float[][][][] maxPool(float[][][][] reLURes) {
        float[][][][] output = new float[reLURes.length][reLURes[0].length][1][1];

        for (int i = 0; i < reLURes.length; i++) {
            for (int j = 0; j < reLURes[0].length; j++) {
                float tmp = Float.MIN_VALUE;
                for (int k = 0; k < reLURes[0][0].length; k++) {
                    tmp = Float.max(tmp, reLURes[i][j][k][0]);
                }
                output[i][j][0][0] = tmp;
            }
        }
        return output;
    }

    private static float[][][][] reLUAndAddBias(float[][][][] convRes, float[][][][] bias) {
        for (int i = 0; i < convRes.length; i++) {
            for (int j = 0; j < bias[0].length; j++) {
                float biasVal = bias[0][j][0][0];
                for (int k = 0; k < convRes[0][0].length; k++) {
                    for (int l = 0; l < convRes[0][0][0].length; l++) {
                        convRes[i][j][k][l] += biasVal;
                        convRes[i][j][k][l] = Float.max(convRes[i][j][k][l], 0);
                    }
                }
            }
        }
        return convRes;
    }

    private static float[][][][] convolve(float[][][][] arr00, float[][][][] arr01, float[][][][] bias) {
        int numberOfProducts = arr00[0][0].length - arr01[0][0].length + 1;
        int numberOfFilters = arr01.length;
        int filterWidth = arr01[0][0].length;
        int wordLength = arr01[0][0][0].length;
        float[][][][] convRes = new float[arr00.length][arr01.length][numberOfProducts][1];

        for (int i = 0; i < arr00.length; i++) {
            for (int j = 0; j < numberOfFilters; j++) {
                for (int k = 0; k < numberOfProducts; k++) {
                    float tmp = 0;
                    for (int l = 0; l < filterWidth; l++) {
                        for (int m = 0; m < wordLength; m++) {
                            tmp += arr00[i][0][k+l][m] * arr01[j][0][filterWidth-l-1][wordLength-m-1];
                        }
                    }
                    convRes[i][j][k][0] = tmp;
                }
            }
        }

        return convRes;
    }

    public static float[] readArr1d(String name, int type){
        String filePath = getPath(name);
        int i;
        if (type == 2) {
            i = 2;
        }else if (type == 6) {
            i = 1031;
        }else{
            i = 1031;
        }
        float[] tArray = new float[i];

        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            for (int ii = 0; ii < i; ii++) {
                tArray[ii] = Float.parseFloat(br.readLine());
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        return tArray;
    }

    public static float[][] readArr2d(String name, int type){
        String filePath = getPath(name);
        int i, j;
        if (type == 0) {
            i = 1031; j = 300;
        }else if (type == 1) {
            i = 300; j = 2;
        }else if (type == 3) {
            i = 1031; j = 2;
        }else if (type == 4) {
            i = 1031; j = 2;
        }else if (type == 5){
            i = 1031; j = 2;
        }else{
            i = 1031; j = 100;
        }
        float[][] tArray = new float[i][j];

        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            for (int ii = 0; ii < i; ii++) {
                for (int jj = 0; jj < j; jj++) {
                    tArray[ii][jj] = Float.parseFloat(br.readLine());
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        return tArray;
    }

    public static float[][][][] readArr4d(String name){
        String filePath = getPath(name);
        int type = Integer.parseInt(name);
        int i, j, k, l;
        if (type == 0) {
            i = 1031; j = 1; k = 64; l = 300;
        }else if (type == 1) {
            i = 100; j = 1; k = 3; l = 300;
        }else if (type == 2) {
            i = 1; j = 100; k = 1; l = 1;
        }else if (type == 10) {
            i = 1031; j = 1; k = 64; l = 300;
        }else if (type == 11) {
            i = 100; j = 1; k = 4; l = 300;
        }else if (type == 12) {
            i = 1; j = 100; k = 1; l = 1;
        }else if (type == 20) {
            i = 1031; j = 1; k = 64; l = 300;
        }else if (type == 21) {
            i = 100; j = 1; k = 5; l = 300;
        }else if (type == 22) {
            i = 1; j = 100; k = 1; l = 1;
        }else{
            i = 1; j = 100; k = 1; l = 1;
        }

        float[][][][] tArray = new float[i][j][k][l];
        int counttt = 0;
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            for (int ii = 0; ii < i; ii++) {
                for (int jj = 0; jj < j; jj++) {
                    for (int kk = 0; kk < k; kk++) {
                        for (int ll = 0; ll < l; ll++) {
                            tArray[ii][jj][kk][ll] = Float.parseFloat(br.readLine());
                        }
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        return tArray;
    }

    private static String getPath(String s) {
        return "/Users/kasrajj/IdeaProjects/CNN/Data/Data"+s+".csv";
    }
}