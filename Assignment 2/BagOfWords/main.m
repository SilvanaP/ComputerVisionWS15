zt% Computer Vision VU
% Assignment 5 - Scene Recognition with Bag of VisualWords
% WS2015

% This script performs the three basic steps of the Bag of visual words
% classification by calling BuildVocabulary, BuildKNN and ClassifyImages.

clc;
close all;
clear all;

C = BuildVocabulary('..\ass5_data\train', 50);

[training, classlabel] = BuildKNN('..\ass5_data\train', C);

% classify and show confusion matrix
confusionMatrix = ClassifyImages('..\ass5_data\test', C, training, classlabel)
%confusionMatrix = ClassifyImages('..\ass5_data\own_testimages', C, training, classlabel)
