function [confusion_matrix,labels] = DoResNet(trainingSetup, image_data_store)
    class_count = length(unique(image_data_store.Labels));
    disp(strcat("processing class count = ", string(class_count)));
    [imdsTrain, imdsValidation, imdsTest] = splitEachLabel(image_data_store,0.7,.1);

    imageAugmenter = imageDataAugmenter(...
        "RandRotation",[-90 90],...
        "RandScale",[1 2],...
        "RandXReflection",true);
    augimdsTrain = augmentedImageDatastore([224 224 3],imdsTrain,"DataAugmentation",imageAugmenter,"ColorPreprocessing","gray2rgb");
    augimdsValidation = augmentedImageDatastore([224 224 3],imdsValidation,"ColorPreprocessing","gray2rgb");

    opts = trainingOptions("sgdm",...
        "ExecutionEnvironment","parallel",...
        "InitialLearnRate",0.01,...
        "Shuffle","every-epoch",...
        "Plots","training-progress",...
        "ValidationData",augimdsValidation);

    lgraph = layerGraph();

    tempLayers = [
        imageInputLayer([224 224 3],"Name","data","Mean",trainingSetup.data.Mean)
        convolution2dLayer([7 7],64,"Name","conv1","BiasLearnRateFactor",0,"Padding",[3 3 3 3],"Stride",[2 2],"Bias",trainingSetup.conv1.Bias,"Weights",trainingSetup.conv1.Weights)
        batchNormalizationLayer("Name","bn_conv1","Offset",trainingSetup.bn_conv1.Offset,"Scale",trainingSetup.bn_conv1.Scale,"TrainedMean",trainingSetup.bn_conv1.TrainedMean,"TrainedVariance",trainingSetup.bn_conv1.TrainedVariance)
        reluLayer("Name","conv1_relu")
        maxPooling2dLayer([3 3],"Name","pool1","Padding",[0 1 0 1],"Stride",[2 2])];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res2a_branch1","BiasLearnRateFactor",0,"Bias",trainingSetup.res2a_branch1.Bias,"Weights",trainingSetup.res2a_branch1.Weights)
        batchNormalizationLayer("Name","bn2a_branch1","Offset",trainingSetup.bn2a_branch1.Offset,"Scale",trainingSetup.bn2a_branch1.Scale,"TrainedMean",trainingSetup.bn2a_branch1.TrainedMean,"TrainedVariance",trainingSetup.bn2a_branch1.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],64,"Name","res2a_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res2a_branch2a.Bias,"Weights",trainingSetup.res2a_branch2a.Weights)
        batchNormalizationLayer("Name","bn2a_branch2a","Offset",trainingSetup.bn2a_branch2a.Offset,"Scale",trainingSetup.bn2a_branch2a.Scale,"TrainedMean",trainingSetup.bn2a_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn2a_branch2a.TrainedVariance)
        reluLayer("Name","res2a_branch2a_relu")
        convolution2dLayer([3 3],64,"Name","res2a_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res2a_branch2b.Bias,"Weights",trainingSetup.res2a_branch2b.Weights)
        batchNormalizationLayer("Name","bn2a_branch2b","Offset",trainingSetup.bn2a_branch2b.Offset,"Scale",trainingSetup.bn2a_branch2b.Scale,"TrainedMean",trainingSetup.bn2a_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn2a_branch2b.TrainedVariance)
        reluLayer("Name","res2a_branch2b_relu")
        convolution2dLayer([1 1],256,"Name","res2a_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res2a_branch2c.Bias,"Weights",trainingSetup.res2a_branch2c.Weights)
        batchNormalizationLayer("Name","bn2a_branch2c","Offset",trainingSetup.bn2a_branch2c.Offset,"Scale",trainingSetup.bn2a_branch2c.Scale,"TrainedMean",trainingSetup.bn2a_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn2a_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res2a")
        reluLayer("Name","res2a_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],64,"Name","res2b_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res2b_branch2a.Bias,"Weights",trainingSetup.res2b_branch2a.Weights)
        batchNormalizationLayer("Name","bn2b_branch2a","Offset",trainingSetup.bn2b_branch2a.Offset,"Scale",trainingSetup.bn2b_branch2a.Scale,"TrainedMean",trainingSetup.bn2b_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn2b_branch2a.TrainedVariance)
        reluLayer("Name","res2b_branch2a_relu")
        convolution2dLayer([3 3],64,"Name","res2b_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res2b_branch2b.Bias,"Weights",trainingSetup.res2b_branch2b.Weights)
        batchNormalizationLayer("Name","bn2b_branch2b","Offset",trainingSetup.bn2b_branch2b.Offset,"Scale",trainingSetup.bn2b_branch2b.Scale,"TrainedMean",trainingSetup.bn2b_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn2b_branch2b.TrainedVariance)
        reluLayer("Name","res2b_branch2b_relu")
        convolution2dLayer([1 1],256,"Name","res2b_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res2b_branch2c.Bias,"Weights",trainingSetup.res2b_branch2c.Weights)
        batchNormalizationLayer("Name","bn2b_branch2c","Offset",trainingSetup.bn2b_branch2c.Offset,"Scale",trainingSetup.bn2b_branch2c.Scale,"TrainedMean",trainingSetup.bn2b_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn2b_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res2b")
        reluLayer("Name","res2b_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],64,"Name","res2c_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res2c_branch2a.Bias,"Weights",trainingSetup.res2c_branch2a.Weights)
        batchNormalizationLayer("Name","bn2c_branch2a","Offset",trainingSetup.bn2c_branch2a.Offset,"Scale",trainingSetup.bn2c_branch2a.Scale,"TrainedMean",trainingSetup.bn2c_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn2c_branch2a.TrainedVariance)
        reluLayer("Name","res2c_branch2a_relu")
        convolution2dLayer([3 3],64,"Name","res2c_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res2c_branch2b.Bias,"Weights",trainingSetup.res2c_branch2b.Weights)
        batchNormalizationLayer("Name","bn2c_branch2b","Offset",trainingSetup.bn2c_branch2b.Offset,"Scale",trainingSetup.bn2c_branch2b.Scale,"TrainedMean",trainingSetup.bn2c_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn2c_branch2b.TrainedVariance)
        reluLayer("Name","res2c_branch2b_relu")
        convolution2dLayer([1 1],256,"Name","res2c_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res2c_branch2c.Bias,"Weights",trainingSetup.res2c_branch2c.Weights)
        batchNormalizationLayer("Name","bn2c_branch2c","Offset",trainingSetup.bn2c_branch2c.Offset,"Scale",trainingSetup.bn2c_branch2c.Scale,"TrainedMean",trainingSetup.bn2c_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn2c_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res2c")
        reluLayer("Name","res2c_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],128,"Name","res3a_branch2a","BiasLearnRateFactor",0,"Stride",[2 2],"Bias",trainingSetup.res3a_branch2a.Bias,"Weights",trainingSetup.res3a_branch2a.Weights)
        batchNormalizationLayer("Name","bn3a_branch2a","Offset",trainingSetup.bn3a_branch2a.Offset,"Scale",trainingSetup.bn3a_branch2a.Scale,"TrainedMean",trainingSetup.bn3a_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn3a_branch2a.TrainedVariance)
        reluLayer("Name","res3a_branch2a_relu")
        convolution2dLayer([3 3],128,"Name","res3a_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res3a_branch2b.Bias,"Weights",trainingSetup.res3a_branch2b.Weights)
        batchNormalizationLayer("Name","bn3a_branch2b","Offset",trainingSetup.bn3a_branch2b.Offset,"Scale",trainingSetup.bn3a_branch2b.Scale,"TrainedMean",trainingSetup.bn3a_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn3a_branch2b.TrainedVariance)
        reluLayer("Name","res3a_branch2b_relu")
        convolution2dLayer([1 1],512,"Name","res3a_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res3a_branch2c.Bias,"Weights",trainingSetup.res3a_branch2c.Weights)
        batchNormalizationLayer("Name","bn3a_branch2c","Offset",trainingSetup.bn3a_branch2c.Offset,"Scale",trainingSetup.bn3a_branch2c.Scale,"TrainedMean",trainingSetup.bn3a_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn3a_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],512,"Name","res3a_branch1","BiasLearnRateFactor",0,"Stride",[2 2],"Bias",trainingSetup.res3a_branch1.Bias,"Weights",trainingSetup.res3a_branch1.Weights)
        batchNormalizationLayer("Name","bn3a_branch1","Offset",trainingSetup.bn3a_branch1.Offset,"Scale",trainingSetup.bn3a_branch1.Scale,"TrainedMean",trainingSetup.bn3a_branch1.TrainedMean,"TrainedVariance",trainingSetup.bn3a_branch1.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res3a")
        reluLayer("Name","res3a_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],128,"Name","res3b1_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res3b1_branch2a.Bias,"Weights",trainingSetup.res3b1_branch2a.Weights)
        batchNormalizationLayer("Name","bn3b1_branch2a","Offset",trainingSetup.bn3b1_branch2a.Offset,"Scale",trainingSetup.bn3b1_branch2a.Scale,"TrainedMean",trainingSetup.bn3b1_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn3b1_branch2a.TrainedVariance)
        reluLayer("Name","res3b1_branch2a_relu")
        convolution2dLayer([3 3],128,"Name","res3b1_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res3b1_branch2b.Bias,"Weights",trainingSetup.res3b1_branch2b.Weights)
        batchNormalizationLayer("Name","bn3b1_branch2b","Offset",trainingSetup.bn3b1_branch2b.Offset,"Scale",trainingSetup.bn3b1_branch2b.Scale,"TrainedMean",trainingSetup.bn3b1_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn3b1_branch2b.TrainedVariance)
        reluLayer("Name","res3b1_branch2b_relu")
        convolution2dLayer([1 1],512,"Name","res3b1_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res3b1_branch2c.Bias,"Weights",trainingSetup.res3b1_branch2c.Weights)
        batchNormalizationLayer("Name","bn3b1_branch2c","Offset",trainingSetup.bn3b1_branch2c.Offset,"Scale",trainingSetup.bn3b1_branch2c.Scale,"TrainedMean",trainingSetup.bn3b1_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn3b1_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res3b1")
        reluLayer("Name","res3b1_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],128,"Name","res3b2_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res3b2_branch2a.Bias,"Weights",trainingSetup.res3b2_branch2a.Weights)
        batchNormalizationLayer("Name","bn3b2_branch2a","Offset",trainingSetup.bn3b2_branch2a.Offset,"Scale",trainingSetup.bn3b2_branch2a.Scale,"TrainedMean",trainingSetup.bn3b2_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn3b2_branch2a.TrainedVariance)
        reluLayer("Name","res3b2_branch2a_relu")
        convolution2dLayer([3 3],128,"Name","res3b2_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res3b2_branch2b.Bias,"Weights",trainingSetup.res3b2_branch2b.Weights)
        batchNormalizationLayer("Name","bn3b2_branch2b","Offset",trainingSetup.bn3b2_branch2b.Offset,"Scale",trainingSetup.bn3b2_branch2b.Scale,"TrainedMean",trainingSetup.bn3b2_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn3b2_branch2b.TrainedVariance)
        reluLayer("Name","res3b2_branch2b_relu")
        convolution2dLayer([1 1],512,"Name","res3b2_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res3b2_branch2c.Bias,"Weights",trainingSetup.res3b2_branch2c.Weights)
        batchNormalizationLayer("Name","bn3b2_branch2c","Offset",trainingSetup.bn3b2_branch2c.Offset,"Scale",trainingSetup.bn3b2_branch2c.Scale,"TrainedMean",trainingSetup.bn3b2_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn3b2_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res3b2")
        reluLayer("Name","res3b2_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],128,"Name","res3b3_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res3b3_branch2a.Bias,"Weights",trainingSetup.res3b3_branch2a.Weights)
        batchNormalizationLayer("Name","bn3b3_branch2a","Offset",trainingSetup.bn3b3_branch2a.Offset,"Scale",trainingSetup.bn3b3_branch2a.Scale,"TrainedMean",trainingSetup.bn3b3_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn3b3_branch2a.TrainedVariance)
        reluLayer("Name","res3b3_branch2a_relu")
        convolution2dLayer([3 3],128,"Name","res3b3_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res3b3_branch2b.Bias,"Weights",trainingSetup.res3b3_branch2b.Weights)
        batchNormalizationLayer("Name","bn3b3_branch2b","Offset",trainingSetup.bn3b3_branch2b.Offset,"Scale",trainingSetup.bn3b3_branch2b.Scale,"TrainedMean",trainingSetup.bn3b3_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn3b3_branch2b.TrainedVariance)
        reluLayer("Name","res3b3_branch2b_relu")
        convolution2dLayer([1 1],512,"Name","res3b3_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res3b3_branch2c.Bias,"Weights",trainingSetup.res3b3_branch2c.Weights)
        batchNormalizationLayer("Name","bn3b3_branch2c","Offset",trainingSetup.bn3b3_branch2c.Offset,"Scale",trainingSetup.bn3b3_branch2c.Scale,"TrainedMean",trainingSetup.bn3b3_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn3b3_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res3b3")
        reluLayer("Name","res3b3_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4a_branch2a","BiasLearnRateFactor",0,"Stride",[2 2],"Bias",trainingSetup.res4a_branch2a.Bias,"Weights",trainingSetup.res4a_branch2a.Weights)
        batchNormalizationLayer("Name","bn4a_branch2a","Offset",trainingSetup.bn4a_branch2a.Offset,"Scale",trainingSetup.bn4a_branch2a.Scale,"TrainedMean",trainingSetup.bn4a_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4a_branch2a.TrainedVariance)
        reluLayer("Name","res4a_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4a_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4a_branch2b.Bias,"Weights",trainingSetup.res4a_branch2b.Weights)
        batchNormalizationLayer("Name","bn4a_branch2b","Offset",trainingSetup.bn4a_branch2b.Offset,"Scale",trainingSetup.bn4a_branch2b.Scale,"TrainedMean",trainingSetup.bn4a_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4a_branch2b.TrainedVariance)
        reluLayer("Name","res4a_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4a_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4a_branch2c.Bias,"Weights",trainingSetup.res4a_branch2c.Weights)
        batchNormalizationLayer("Name","bn4a_branch2c","Offset",trainingSetup.bn4a_branch2c.Offset,"Scale",trainingSetup.bn4a_branch2c.Scale,"TrainedMean",trainingSetup.bn4a_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4a_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],1024,"Name","res4a_branch1","BiasLearnRateFactor",0,"Stride",[2 2],"Bias",trainingSetup.res4a_branch1.Bias,"Weights",trainingSetup.res4a_branch1.Weights)
        batchNormalizationLayer("Name","bn4a_branch1","Offset",trainingSetup.bn4a_branch1.Offset,"Scale",trainingSetup.bn4a_branch1.Scale,"TrainedMean",trainingSetup.bn4a_branch1.TrainedMean,"TrainedVariance",trainingSetup.bn4a_branch1.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4a")
        reluLayer("Name","res4a_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b1_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b1_branch2a.Bias,"Weights",trainingSetup.res4b1_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b1_branch2a","Offset",trainingSetup.bn4b1_branch2a.Offset,"Scale",trainingSetup.bn4b1_branch2a.Scale,"TrainedMean",trainingSetup.bn4b1_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b1_branch2a.TrainedVariance)
        reluLayer("Name","res4b1_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b1_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b1_branch2b.Bias,"Weights",trainingSetup.res4b1_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b1_branch2b","Offset",trainingSetup.bn4b1_branch2b.Offset,"Scale",trainingSetup.bn4b1_branch2b.Scale,"TrainedMean",trainingSetup.bn4b1_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b1_branch2b.TrainedVariance)
        reluLayer("Name","res4b1_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b1_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b1_branch2c.Bias,"Weights",trainingSetup.res4b1_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b1_branch2c","Offset",trainingSetup.bn4b1_branch2c.Offset,"Scale",trainingSetup.bn4b1_branch2c.Scale,"TrainedMean",trainingSetup.bn4b1_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b1_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b1")
        reluLayer("Name","res4b1_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b2_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b2_branch2a.Bias,"Weights",trainingSetup.res4b2_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b2_branch2a","Offset",trainingSetup.bn4b2_branch2a.Offset,"Scale",trainingSetup.bn4b2_branch2a.Scale,"TrainedMean",trainingSetup.bn4b2_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b2_branch2a.TrainedVariance)
        reluLayer("Name","res4b2_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b2_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b2_branch2b.Bias,"Weights",trainingSetup.res4b2_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b2_branch2b","Offset",trainingSetup.bn4b2_branch2b.Offset,"Scale",trainingSetup.bn4b2_branch2b.Scale,"TrainedMean",trainingSetup.bn4b2_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b2_branch2b.TrainedVariance)
        reluLayer("Name","res4b2_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b2_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b2_branch2c.Bias,"Weights",trainingSetup.res4b2_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b2_branch2c","Offset",trainingSetup.bn4b2_branch2c.Offset,"Scale",trainingSetup.bn4b2_branch2c.Scale,"TrainedMean",trainingSetup.bn4b2_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b2_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b2")
        reluLayer("Name","res4b2_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b3_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b3_branch2a.Bias,"Weights",trainingSetup.res4b3_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b3_branch2a","Offset",trainingSetup.bn4b3_branch2a.Offset,"Scale",trainingSetup.bn4b3_branch2a.Scale,"TrainedMean",trainingSetup.bn4b3_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b3_branch2a.TrainedVariance)
        reluLayer("Name","res4b3_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b3_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b3_branch2b.Bias,"Weights",trainingSetup.res4b3_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b3_branch2b","Offset",trainingSetup.bn4b3_branch2b.Offset,"Scale",trainingSetup.bn4b3_branch2b.Scale,"TrainedMean",trainingSetup.bn4b3_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b3_branch2b.TrainedVariance)
        reluLayer("Name","res4b3_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b3_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b3_branch2c.Bias,"Weights",trainingSetup.res4b3_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b3_branch2c","Offset",trainingSetup.bn4b3_branch2c.Offset,"Scale",trainingSetup.bn4b3_branch2c.Scale,"TrainedMean",trainingSetup.bn4b3_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b3_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b3")
        reluLayer("Name","res4b3_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b4_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b4_branch2a.Bias,"Weights",trainingSetup.res4b4_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b4_branch2a","Offset",trainingSetup.bn4b4_branch2a.Offset,"Scale",trainingSetup.bn4b4_branch2a.Scale,"TrainedMean",trainingSetup.bn4b4_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b4_branch2a.TrainedVariance)
        reluLayer("Name","res4b4_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b4_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b4_branch2b.Bias,"Weights",trainingSetup.res4b4_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b4_branch2b","Offset",trainingSetup.bn4b4_branch2b.Offset,"Scale",trainingSetup.bn4b4_branch2b.Scale,"TrainedMean",trainingSetup.bn4b4_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b4_branch2b.TrainedVariance)
        reluLayer("Name","res4b4_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b4_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b4_branch2c.Bias,"Weights",trainingSetup.res4b4_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b4_branch2c","Offset",trainingSetup.bn4b4_branch2c.Offset,"Scale",trainingSetup.bn4b4_branch2c.Scale,"TrainedMean",trainingSetup.bn4b4_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b4_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b4")
        reluLayer("Name","res4b4_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b5_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b5_branch2a.Bias,"Weights",trainingSetup.res4b5_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b5_branch2a","Offset",trainingSetup.bn4b5_branch2a.Offset,"Scale",trainingSetup.bn4b5_branch2a.Scale,"TrainedMean",trainingSetup.bn4b5_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b5_branch2a.TrainedVariance)
        reluLayer("Name","res4b5_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b5_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b5_branch2b.Bias,"Weights",trainingSetup.res4b5_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b5_branch2b","Offset",trainingSetup.bn4b5_branch2b.Offset,"Scale",trainingSetup.bn4b5_branch2b.Scale,"TrainedMean",trainingSetup.bn4b5_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b5_branch2b.TrainedVariance)
        reluLayer("Name","res4b5_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b5_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b5_branch2c.Bias,"Weights",trainingSetup.res4b5_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b5_branch2c","Offset",trainingSetup.bn4b5_branch2c.Offset,"Scale",trainingSetup.bn4b5_branch2c.Scale,"TrainedMean",trainingSetup.bn4b5_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b5_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b5")
        reluLayer("Name","res4b5_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b6_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b6_branch2a.Bias,"Weights",trainingSetup.res4b6_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b6_branch2a","Offset",trainingSetup.bn4b6_branch2a.Offset,"Scale",trainingSetup.bn4b6_branch2a.Scale,"TrainedMean",trainingSetup.bn4b6_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b6_branch2a.TrainedVariance)
        reluLayer("Name","res4b6_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b6_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b6_branch2b.Bias,"Weights",trainingSetup.res4b6_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b6_branch2b","Offset",trainingSetup.bn4b6_branch2b.Offset,"Scale",trainingSetup.bn4b6_branch2b.Scale,"TrainedMean",trainingSetup.bn4b6_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b6_branch2b.TrainedVariance)
        reluLayer("Name","res4b6_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b6_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b6_branch2c.Bias,"Weights",trainingSetup.res4b6_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b6_branch2c","Offset",trainingSetup.bn4b6_branch2c.Offset,"Scale",trainingSetup.bn4b6_branch2c.Scale,"TrainedMean",trainingSetup.bn4b6_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b6_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b6")
        reluLayer("Name","res4b6_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b7_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b7_branch2a.Bias,"Weights",trainingSetup.res4b7_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b7_branch2a","Offset",trainingSetup.bn4b7_branch2a.Offset,"Scale",trainingSetup.bn4b7_branch2a.Scale,"TrainedMean",trainingSetup.bn4b7_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b7_branch2a.TrainedVariance)
        reluLayer("Name","res4b7_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b7_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b7_branch2b.Bias,"Weights",trainingSetup.res4b7_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b7_branch2b","Offset",trainingSetup.bn4b7_branch2b.Offset,"Scale",trainingSetup.bn4b7_branch2b.Scale,"TrainedMean",trainingSetup.bn4b7_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b7_branch2b.TrainedVariance)
        reluLayer("Name","res4b7_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b7_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b7_branch2c.Bias,"Weights",trainingSetup.res4b7_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b7_branch2c","Offset",trainingSetup.bn4b7_branch2c.Offset,"Scale",trainingSetup.bn4b7_branch2c.Scale,"TrainedMean",trainingSetup.bn4b7_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b7_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b7")
        reluLayer("Name","res4b7_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b8_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b8_branch2a.Bias,"Weights",trainingSetup.res4b8_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b8_branch2a","Offset",trainingSetup.bn4b8_branch2a.Offset,"Scale",trainingSetup.bn4b8_branch2a.Scale,"TrainedMean",trainingSetup.bn4b8_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b8_branch2a.TrainedVariance)
        reluLayer("Name","res4b8_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b8_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b8_branch2b.Bias,"Weights",trainingSetup.res4b8_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b8_branch2b","Offset",trainingSetup.bn4b8_branch2b.Offset,"Scale",trainingSetup.bn4b8_branch2b.Scale,"TrainedMean",trainingSetup.bn4b8_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b8_branch2b.TrainedVariance)
        reluLayer("Name","res4b8_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b8_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b8_branch2c.Bias,"Weights",trainingSetup.res4b8_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b8_branch2c","Offset",trainingSetup.bn4b8_branch2c.Offset,"Scale",trainingSetup.bn4b8_branch2c.Scale,"TrainedMean",trainingSetup.bn4b8_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b8_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b8")
        reluLayer("Name","res4b8_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b9_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b9_branch2a.Bias,"Weights",trainingSetup.res4b9_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b9_branch2a","Offset",trainingSetup.bn4b9_branch2a.Offset,"Scale",trainingSetup.bn4b9_branch2a.Scale,"TrainedMean",trainingSetup.bn4b9_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b9_branch2a.TrainedVariance)
        reluLayer("Name","res4b9_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b9_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b9_branch2b.Bias,"Weights",trainingSetup.res4b9_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b9_branch2b","Offset",trainingSetup.bn4b9_branch2b.Offset,"Scale",trainingSetup.bn4b9_branch2b.Scale,"TrainedMean",trainingSetup.bn4b9_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b9_branch2b.TrainedVariance)
        reluLayer("Name","res4b9_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b9_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b9_branch2c.Bias,"Weights",trainingSetup.res4b9_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b9_branch2c","Offset",trainingSetup.bn4b9_branch2c.Offset,"Scale",trainingSetup.bn4b9_branch2c.Scale,"TrainedMean",trainingSetup.bn4b9_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b9_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b9")
        reluLayer("Name","res4b9_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b10_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b10_branch2a.Bias,"Weights",trainingSetup.res4b10_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b10_branch2a","Offset",trainingSetup.bn4b10_branch2a.Offset,"Scale",trainingSetup.bn4b10_branch2a.Scale,"TrainedMean",trainingSetup.bn4b10_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b10_branch2a.TrainedVariance)
        reluLayer("Name","res4b10_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b10_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b10_branch2b.Bias,"Weights",trainingSetup.res4b10_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b10_branch2b","Offset",trainingSetup.bn4b10_branch2b.Offset,"Scale",trainingSetup.bn4b10_branch2b.Scale,"TrainedMean",trainingSetup.bn4b10_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b10_branch2b.TrainedVariance)
        reluLayer("Name","res4b10_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b10_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b10_branch2c.Bias,"Weights",trainingSetup.res4b10_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b10_branch2c","Offset",trainingSetup.bn4b10_branch2c.Offset,"Scale",trainingSetup.bn4b10_branch2c.Scale,"TrainedMean",trainingSetup.bn4b10_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b10_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b10")
        reluLayer("Name","res4b10_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b11_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b11_branch2a.Bias,"Weights",trainingSetup.res4b11_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b11_branch2a","Offset",trainingSetup.bn4b11_branch2a.Offset,"Scale",trainingSetup.bn4b11_branch2a.Scale,"TrainedMean",trainingSetup.bn4b11_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b11_branch2a.TrainedVariance)
        reluLayer("Name","res4b11_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b11_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b11_branch2b.Bias,"Weights",trainingSetup.res4b11_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b11_branch2b","Offset",trainingSetup.bn4b11_branch2b.Offset,"Scale",trainingSetup.bn4b11_branch2b.Scale,"TrainedMean",trainingSetup.bn4b11_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b11_branch2b.TrainedVariance)
        reluLayer("Name","res4b11_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b11_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b11_branch2c.Bias,"Weights",trainingSetup.res4b11_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b11_branch2c","Offset",trainingSetup.bn4b11_branch2c.Offset,"Scale",trainingSetup.bn4b11_branch2c.Scale,"TrainedMean",trainingSetup.bn4b11_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b11_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b11")
        reluLayer("Name","res4b11_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b12_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b12_branch2a.Bias,"Weights",trainingSetup.res4b12_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b12_branch2a","Offset",trainingSetup.bn4b12_branch2a.Offset,"Scale",trainingSetup.bn4b12_branch2a.Scale,"TrainedMean",trainingSetup.bn4b12_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b12_branch2a.TrainedVariance)
        reluLayer("Name","res4b12_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b12_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b12_branch2b.Bias,"Weights",trainingSetup.res4b12_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b12_branch2b","Offset",trainingSetup.bn4b12_branch2b.Offset,"Scale",trainingSetup.bn4b12_branch2b.Scale,"TrainedMean",trainingSetup.bn4b12_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b12_branch2b.TrainedVariance)
        reluLayer("Name","res4b12_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b12_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b12_branch2c.Bias,"Weights",trainingSetup.res4b12_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b12_branch2c","Offset",trainingSetup.bn4b12_branch2c.Offset,"Scale",trainingSetup.bn4b12_branch2c.Scale,"TrainedMean",trainingSetup.bn4b12_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b12_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b12")
        reluLayer("Name","res4b12_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b13_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b13_branch2a.Bias,"Weights",trainingSetup.res4b13_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b13_branch2a","Offset",trainingSetup.bn4b13_branch2a.Offset,"Scale",trainingSetup.bn4b13_branch2a.Scale,"TrainedMean",trainingSetup.bn4b13_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b13_branch2a.TrainedVariance)
        reluLayer("Name","res4b13_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b13_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b13_branch2b.Bias,"Weights",trainingSetup.res4b13_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b13_branch2b","Offset",trainingSetup.bn4b13_branch2b.Offset,"Scale",trainingSetup.bn4b13_branch2b.Scale,"TrainedMean",trainingSetup.bn4b13_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b13_branch2b.TrainedVariance)
        reluLayer("Name","res4b13_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b13_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b13_branch2c.Bias,"Weights",trainingSetup.res4b13_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b13_branch2c","Offset",trainingSetup.bn4b13_branch2c.Offset,"Scale",trainingSetup.bn4b13_branch2c.Scale,"TrainedMean",trainingSetup.bn4b13_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b13_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b13")
        reluLayer("Name","res4b13_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b14_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b14_branch2a.Bias,"Weights",trainingSetup.res4b14_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b14_branch2a","Offset",trainingSetup.bn4b14_branch2a.Offset,"Scale",trainingSetup.bn4b14_branch2a.Scale,"TrainedMean",trainingSetup.bn4b14_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b14_branch2a.TrainedVariance)
        reluLayer("Name","res4b14_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b14_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b14_branch2b.Bias,"Weights",trainingSetup.res4b14_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b14_branch2b","Offset",trainingSetup.bn4b14_branch2b.Offset,"Scale",trainingSetup.bn4b14_branch2b.Scale,"TrainedMean",trainingSetup.bn4b14_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b14_branch2b.TrainedVariance)
        reluLayer("Name","res4b14_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b14_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b14_branch2c.Bias,"Weights",trainingSetup.res4b14_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b14_branch2c","Offset",trainingSetup.bn4b14_branch2c.Offset,"Scale",trainingSetup.bn4b14_branch2c.Scale,"TrainedMean",trainingSetup.bn4b14_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b14_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b14")
        reluLayer("Name","res4b14_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b15_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b15_branch2a.Bias,"Weights",trainingSetup.res4b15_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b15_branch2a","Offset",trainingSetup.bn4b15_branch2a.Offset,"Scale",trainingSetup.bn4b15_branch2a.Scale,"TrainedMean",trainingSetup.bn4b15_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b15_branch2a.TrainedVariance)
        reluLayer("Name","res4b15_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b15_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b15_branch2b.Bias,"Weights",trainingSetup.res4b15_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b15_branch2b","Offset",trainingSetup.bn4b15_branch2b.Offset,"Scale",trainingSetup.bn4b15_branch2b.Scale,"TrainedMean",trainingSetup.bn4b15_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b15_branch2b.TrainedVariance)
        reluLayer("Name","res4b15_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b15_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b15_branch2c.Bias,"Weights",trainingSetup.res4b15_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b15_branch2c","Offset",trainingSetup.bn4b15_branch2c.Offset,"Scale",trainingSetup.bn4b15_branch2c.Scale,"TrainedMean",trainingSetup.bn4b15_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b15_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b15")
        reluLayer("Name","res4b15_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b16_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b16_branch2a.Bias,"Weights",trainingSetup.res4b16_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b16_branch2a","Offset",trainingSetup.bn4b16_branch2a.Offset,"Scale",trainingSetup.bn4b16_branch2a.Scale,"TrainedMean",trainingSetup.bn4b16_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b16_branch2a.TrainedVariance)
        reluLayer("Name","res4b16_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b16_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b16_branch2b.Bias,"Weights",trainingSetup.res4b16_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b16_branch2b","Offset",trainingSetup.bn4b16_branch2b.Offset,"Scale",trainingSetup.bn4b16_branch2b.Scale,"TrainedMean",trainingSetup.bn4b16_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b16_branch2b.TrainedVariance)
        reluLayer("Name","res4b16_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b16_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b16_branch2c.Bias,"Weights",trainingSetup.res4b16_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b16_branch2c","Offset",trainingSetup.bn4b16_branch2c.Offset,"Scale",trainingSetup.bn4b16_branch2c.Scale,"TrainedMean",trainingSetup.bn4b16_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b16_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b16")
        reluLayer("Name","res4b16_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b17_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b17_branch2a.Bias,"Weights",trainingSetup.res4b17_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b17_branch2a","Offset",trainingSetup.bn4b17_branch2a.Offset,"Scale",trainingSetup.bn4b17_branch2a.Scale,"TrainedMean",trainingSetup.bn4b17_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b17_branch2a.TrainedVariance)
        reluLayer("Name","res4b17_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b17_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b17_branch2b.Bias,"Weights",trainingSetup.res4b17_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b17_branch2b","Offset",trainingSetup.bn4b17_branch2b.Offset,"Scale",trainingSetup.bn4b17_branch2b.Scale,"TrainedMean",trainingSetup.bn4b17_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b17_branch2b.TrainedVariance)
        reluLayer("Name","res4b17_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b17_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b17_branch2c.Bias,"Weights",trainingSetup.res4b17_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b17_branch2c","Offset",trainingSetup.bn4b17_branch2c.Offset,"Scale",trainingSetup.bn4b17_branch2c.Scale,"TrainedMean",trainingSetup.bn4b17_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b17_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b17")
        reluLayer("Name","res4b17_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b18_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b18_branch2a.Bias,"Weights",trainingSetup.res4b18_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b18_branch2a","Offset",trainingSetup.bn4b18_branch2a.Offset,"Scale",trainingSetup.bn4b18_branch2a.Scale,"TrainedMean",trainingSetup.bn4b18_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b18_branch2a.TrainedVariance)
        reluLayer("Name","res4b18_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b18_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b18_branch2b.Bias,"Weights",trainingSetup.res4b18_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b18_branch2b","Offset",trainingSetup.bn4b18_branch2b.Offset,"Scale",trainingSetup.bn4b18_branch2b.Scale,"TrainedMean",trainingSetup.bn4b18_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b18_branch2b.TrainedVariance)
        reluLayer("Name","res4b18_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b18_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b18_branch2c.Bias,"Weights",trainingSetup.res4b18_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b18_branch2c","Offset",trainingSetup.bn4b18_branch2c.Offset,"Scale",trainingSetup.bn4b18_branch2c.Scale,"TrainedMean",trainingSetup.bn4b18_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b18_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b18")
        reluLayer("Name","res4b18_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b19_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b19_branch2a.Bias,"Weights",trainingSetup.res4b19_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b19_branch2a","Offset",trainingSetup.bn4b19_branch2a.Offset,"Scale",trainingSetup.bn4b19_branch2a.Scale,"TrainedMean",trainingSetup.bn4b19_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b19_branch2a.TrainedVariance)
        reluLayer("Name","res4b19_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b19_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b19_branch2b.Bias,"Weights",trainingSetup.res4b19_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b19_branch2b","Offset",trainingSetup.bn4b19_branch2b.Offset,"Scale",trainingSetup.bn4b19_branch2b.Scale,"TrainedMean",trainingSetup.bn4b19_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b19_branch2b.TrainedVariance)
        reluLayer("Name","res4b19_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b19_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b19_branch2c.Bias,"Weights",trainingSetup.res4b19_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b19_branch2c","Offset",trainingSetup.bn4b19_branch2c.Offset,"Scale",trainingSetup.bn4b19_branch2c.Scale,"TrainedMean",trainingSetup.bn4b19_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b19_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b19")
        reluLayer("Name","res4b19_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b20_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b20_branch2a.Bias,"Weights",trainingSetup.res4b20_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b20_branch2a","Offset",trainingSetup.bn4b20_branch2a.Offset,"Scale",trainingSetup.bn4b20_branch2a.Scale,"TrainedMean",trainingSetup.bn4b20_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b20_branch2a.TrainedVariance)
        reluLayer("Name","res4b20_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b20_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b20_branch2b.Bias,"Weights",trainingSetup.res4b20_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b20_branch2b","Offset",trainingSetup.bn4b20_branch2b.Offset,"Scale",trainingSetup.bn4b20_branch2b.Scale,"TrainedMean",trainingSetup.bn4b20_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b20_branch2b.TrainedVariance)
        reluLayer("Name","res4b20_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b20_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b20_branch2c.Bias,"Weights",trainingSetup.res4b20_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b20_branch2c","Offset",trainingSetup.bn4b20_branch2c.Offset,"Scale",trainingSetup.bn4b20_branch2c.Scale,"TrainedMean",trainingSetup.bn4b20_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b20_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b20")
        reluLayer("Name","res4b20_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b21_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b21_branch2a.Bias,"Weights",trainingSetup.res4b21_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b21_branch2a","Offset",trainingSetup.bn4b21_branch2a.Offset,"Scale",trainingSetup.bn4b21_branch2a.Scale,"TrainedMean",trainingSetup.bn4b21_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b21_branch2a.TrainedVariance)
        reluLayer("Name","res4b21_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b21_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b21_branch2b.Bias,"Weights",trainingSetup.res4b21_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b21_branch2b","Offset",trainingSetup.bn4b21_branch2b.Offset,"Scale",trainingSetup.bn4b21_branch2b.Scale,"TrainedMean",trainingSetup.bn4b21_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b21_branch2b.TrainedVariance)
        reluLayer("Name","res4b21_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b21_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b21_branch2c.Bias,"Weights",trainingSetup.res4b21_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b21_branch2c","Offset",trainingSetup.bn4b21_branch2c.Offset,"Scale",trainingSetup.bn4b21_branch2c.Scale,"TrainedMean",trainingSetup.bn4b21_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b21_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b21")
        reluLayer("Name","res4b21_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],256,"Name","res4b22_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b22_branch2a.Bias,"Weights",trainingSetup.res4b22_branch2a.Weights)
        batchNormalizationLayer("Name","bn4b22_branch2a","Offset",trainingSetup.bn4b22_branch2a.Offset,"Scale",trainingSetup.bn4b22_branch2a.Scale,"TrainedMean",trainingSetup.bn4b22_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn4b22_branch2a.TrainedVariance)
        reluLayer("Name","res4b22_branch2a_relu")
        convolution2dLayer([3 3],256,"Name","res4b22_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res4b22_branch2b.Bias,"Weights",trainingSetup.res4b22_branch2b.Weights)
        batchNormalizationLayer("Name","bn4b22_branch2b","Offset",trainingSetup.bn4b22_branch2b.Offset,"Scale",trainingSetup.bn4b22_branch2b.Scale,"TrainedMean",trainingSetup.bn4b22_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn4b22_branch2b.TrainedVariance)
        reluLayer("Name","res4b22_branch2b_relu")
        convolution2dLayer([1 1],1024,"Name","res4b22_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res4b22_branch2c.Bias,"Weights",trainingSetup.res4b22_branch2c.Weights)
        batchNormalizationLayer("Name","bn4b22_branch2c","Offset",trainingSetup.bn4b22_branch2c.Offset,"Scale",trainingSetup.bn4b22_branch2c.Scale,"TrainedMean",trainingSetup.bn4b22_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn4b22_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res4b22")
        reluLayer("Name","res4b22_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],2048,"Name","res5a_branch1","BiasLearnRateFactor",0,"Stride",[2 2],"Bias",trainingSetup.res5a_branch1.Bias,"Weights",trainingSetup.res5a_branch1.Weights)
        batchNormalizationLayer("Name","bn5a_branch1","Offset",trainingSetup.bn5a_branch1.Offset,"Scale",trainingSetup.bn5a_branch1.Scale,"TrainedMean",trainingSetup.bn5a_branch1.TrainedMean,"TrainedVariance",trainingSetup.bn5a_branch1.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],512,"Name","res5a_branch2a","BiasLearnRateFactor",0,"Stride",[2 2],"Bias",trainingSetup.res5a_branch2a.Bias,"Weights",trainingSetup.res5a_branch2a.Weights)
        batchNormalizationLayer("Name","bn5a_branch2a","Offset",trainingSetup.bn5a_branch2a.Offset,"Scale",trainingSetup.bn5a_branch2a.Scale,"TrainedMean",trainingSetup.bn5a_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn5a_branch2a.TrainedVariance)
        reluLayer("Name","res5a_branch2a_relu")
        convolution2dLayer([3 3],512,"Name","res5a_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res5a_branch2b.Bias,"Weights",trainingSetup.res5a_branch2b.Weights)
        batchNormalizationLayer("Name","bn5a_branch2b","Offset",trainingSetup.bn5a_branch2b.Offset,"Scale",trainingSetup.bn5a_branch2b.Scale,"TrainedMean",trainingSetup.bn5a_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn5a_branch2b.TrainedVariance)
        reluLayer("Name","res5a_branch2b_relu")
        convolution2dLayer([1 1],2048,"Name","res5a_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res5a_branch2c.Bias,"Weights",trainingSetup.res5a_branch2c.Weights)
        batchNormalizationLayer("Name","bn5a_branch2c","Offset",trainingSetup.bn5a_branch2c.Offset,"Scale",trainingSetup.bn5a_branch2c.Scale,"TrainedMean",trainingSetup.bn5a_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn5a_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res5a")
        reluLayer("Name","res5a_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],512,"Name","res5b_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res5b_branch2a.Bias,"Weights",trainingSetup.res5b_branch2a.Weights)
        batchNormalizationLayer("Name","bn5b_branch2a","Offset",trainingSetup.bn5b_branch2a.Offset,"Scale",trainingSetup.bn5b_branch2a.Scale,"TrainedMean",trainingSetup.bn5b_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn5b_branch2a.TrainedVariance)
        reluLayer("Name","res5b_branch2a_relu")
        convolution2dLayer([3 3],512,"Name","res5b_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res5b_branch2b.Bias,"Weights",trainingSetup.res5b_branch2b.Weights)
        batchNormalizationLayer("Name","bn5b_branch2b","Offset",trainingSetup.bn5b_branch2b.Offset,"Scale",trainingSetup.bn5b_branch2b.Scale,"TrainedMean",trainingSetup.bn5b_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn5b_branch2b.TrainedVariance)
        reluLayer("Name","res5b_branch2b_relu")
        convolution2dLayer([1 1],2048,"Name","res5b_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res5b_branch2c.Bias,"Weights",trainingSetup.res5b_branch2c.Weights)
        batchNormalizationLayer("Name","bn5b_branch2c","Offset",trainingSetup.bn5b_branch2c.Offset,"Scale",trainingSetup.bn5b_branch2c.Scale,"TrainedMean",trainingSetup.bn5b_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn5b_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res5b")
        reluLayer("Name","res5b_relu")];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        convolution2dLayer([1 1],512,"Name","res5c_branch2a","BiasLearnRateFactor",0,"Bias",trainingSetup.res5c_branch2a.Bias,"Weights",trainingSetup.res5c_branch2a.Weights)
        batchNormalizationLayer("Name","bn5c_branch2a","Offset",trainingSetup.bn5c_branch2a.Offset,"Scale",trainingSetup.bn5c_branch2a.Scale,"TrainedMean",trainingSetup.bn5c_branch2a.TrainedMean,"TrainedVariance",trainingSetup.bn5c_branch2a.TrainedVariance)
        reluLayer("Name","res5c_branch2a_relu")
        convolution2dLayer([3 3],512,"Name","res5c_branch2b","BiasLearnRateFactor",0,"Padding",[1 1 1 1],"Bias",trainingSetup.res5c_branch2b.Bias,"Weights",trainingSetup.res5c_branch2b.Weights)
        batchNormalizationLayer("Name","bn5c_branch2b","Offset",trainingSetup.bn5c_branch2b.Offset,"Scale",trainingSetup.bn5c_branch2b.Scale,"TrainedMean",trainingSetup.bn5c_branch2b.TrainedMean,"TrainedVariance",trainingSetup.bn5c_branch2b.TrainedVariance)
        reluLayer("Name","res5c_branch2b_relu")
        convolution2dLayer([1 1],2048,"Name","res5c_branch2c","BiasLearnRateFactor",0,"Bias",trainingSetup.res5c_branch2c.Bias,"Weights",trainingSetup.res5c_branch2c.Weights)
        batchNormalizationLayer("Name","bn5c_branch2c","Offset",trainingSetup.bn5c_branch2c.Offset,"Scale",trainingSetup.bn5c_branch2c.Scale,"TrainedMean",trainingSetup.bn5c_branch2c.TrainedMean,"TrainedVariance",trainingSetup.bn5c_branch2c.TrainedVariance)];
    lgraph = addLayers(lgraph,tempLayers);

    tempLayers = [
        additionLayer(2,"Name","res5c")
        reluLayer("Name","res5c_relu")
        globalAveragePooling2dLayer("Name","pool5")
        fullyConnectedLayer(class_count,"Name","fc")
        softmaxLayer("Name","prob")
        classificationLayer("Name","classoutput")];
    lgraph = addLayers(lgraph,tempLayers);

    clear tempLayers;

    lgraph = connectLayers(lgraph,"pool1","res2a_branch1");
    lgraph = connectLayers(lgraph,"pool1","res2a_branch2a");
    lgraph = connectLayers(lgraph,"bn2a_branch2c","res2a/in1");
    lgraph = connectLayers(lgraph,"bn2a_branch1","res2a/in2");
    lgraph = connectLayers(lgraph,"res2a_relu","res2b_branch2a");
    lgraph = connectLayers(lgraph,"res2a_relu","res2b/in2");
    lgraph = connectLayers(lgraph,"bn2b_branch2c","res2b/in1");
    lgraph = connectLayers(lgraph,"res2b_relu","res2c_branch2a");
    lgraph = connectLayers(lgraph,"res2b_relu","res2c/in2");
    lgraph = connectLayers(lgraph,"bn2c_branch2c","res2c/in1");
    lgraph = connectLayers(lgraph,"res2c_relu","res3a_branch2a");
    lgraph = connectLayers(lgraph,"res2c_relu","res3a_branch1");
    lgraph = connectLayers(lgraph,"bn3a_branch1","res3a/in2");
    lgraph = connectLayers(lgraph,"bn3a_branch2c","res3a/in1");
    lgraph = connectLayers(lgraph,"res3a_relu","res3b1_branch2a");
    lgraph = connectLayers(lgraph,"res3a_relu","res3b1/in2");
    lgraph = connectLayers(lgraph,"bn3b1_branch2c","res3b1/in1");
    lgraph = connectLayers(lgraph,"res3b1_relu","res3b2_branch2a");
    lgraph = connectLayers(lgraph,"res3b1_relu","res3b2/in2");
    lgraph = connectLayers(lgraph,"bn3b2_branch2c","res3b2/in1");
    lgraph = connectLayers(lgraph,"res3b2_relu","res3b3_branch2a");
    lgraph = connectLayers(lgraph,"res3b2_relu","res3b3/in2");
    lgraph = connectLayers(lgraph,"bn3b3_branch2c","res3b3/in1");
    lgraph = connectLayers(lgraph,"res3b3_relu","res4a_branch2a");
    lgraph = connectLayers(lgraph,"res3b3_relu","res4a_branch1");
    lgraph = connectLayers(lgraph,"bn4a_branch1","res4a/in2");
    lgraph = connectLayers(lgraph,"bn4a_branch2c","res4a/in1");
    lgraph = connectLayers(lgraph,"res4a_relu","res4b1_branch2a");
    lgraph = connectLayers(lgraph,"res4a_relu","res4b1/in2");
    lgraph = connectLayers(lgraph,"bn4b1_branch2c","res4b1/in1");
    lgraph = connectLayers(lgraph,"res4b1_relu","res4b2_branch2a");
    lgraph = connectLayers(lgraph,"res4b1_relu","res4b2/in2");
    lgraph = connectLayers(lgraph,"bn4b2_branch2c","res4b2/in1");
    lgraph = connectLayers(lgraph,"res4b2_relu","res4b3_branch2a");
    lgraph = connectLayers(lgraph,"res4b2_relu","res4b3/in2");
    lgraph = connectLayers(lgraph,"bn4b3_branch2c","res4b3/in1");
    lgraph = connectLayers(lgraph,"res4b3_relu","res4b4_branch2a");
    lgraph = connectLayers(lgraph,"res4b3_relu","res4b4/in2");
    lgraph = connectLayers(lgraph,"bn4b4_branch2c","res4b4/in1");
    lgraph = connectLayers(lgraph,"res4b4_relu","res4b5_branch2a");
    lgraph = connectLayers(lgraph,"res4b4_relu","res4b5/in2");
    lgraph = connectLayers(lgraph,"bn4b5_branch2c","res4b5/in1");
    lgraph = connectLayers(lgraph,"res4b5_relu","res4b6_branch2a");
    lgraph = connectLayers(lgraph,"res4b5_relu","res4b6/in2");
    lgraph = connectLayers(lgraph,"bn4b6_branch2c","res4b6/in1");
    lgraph = connectLayers(lgraph,"res4b6_relu","res4b7_branch2a");
    lgraph = connectLayers(lgraph,"res4b6_relu","res4b7/in2");
    lgraph = connectLayers(lgraph,"bn4b7_branch2c","res4b7/in1");
    lgraph = connectLayers(lgraph,"res4b7_relu","res4b8_branch2a");
    lgraph = connectLayers(lgraph,"res4b7_relu","res4b8/in2");
    lgraph = connectLayers(lgraph,"bn4b8_branch2c","res4b8/in1");
    lgraph = connectLayers(lgraph,"res4b8_relu","res4b9_branch2a");
    lgraph = connectLayers(lgraph,"res4b8_relu","res4b9/in2");
    lgraph = connectLayers(lgraph,"bn4b9_branch2c","res4b9/in1");
    lgraph = connectLayers(lgraph,"res4b9_relu","res4b10_branch2a");
    lgraph = connectLayers(lgraph,"res4b9_relu","res4b10/in2");
    lgraph = connectLayers(lgraph,"bn4b10_branch2c","res4b10/in1");
    lgraph = connectLayers(lgraph,"res4b10_relu","res4b11_branch2a");
    lgraph = connectLayers(lgraph,"res4b10_relu","res4b11/in2");
    lgraph = connectLayers(lgraph,"bn4b11_branch2c","res4b11/in1");
    lgraph = connectLayers(lgraph,"res4b11_relu","res4b12_branch2a");
    lgraph = connectLayers(lgraph,"res4b11_relu","res4b12/in2");
    lgraph = connectLayers(lgraph,"bn4b12_branch2c","res4b12/in1");
    lgraph = connectLayers(lgraph,"res4b12_relu","res4b13_branch2a");
    lgraph = connectLayers(lgraph,"res4b12_relu","res4b13/in2");
    lgraph = connectLayers(lgraph,"bn4b13_branch2c","res4b13/in1");
    lgraph = connectLayers(lgraph,"res4b13_relu","res4b14_branch2a");
    lgraph = connectLayers(lgraph,"res4b13_relu","res4b14/in2");
    lgraph = connectLayers(lgraph,"bn4b14_branch2c","res4b14/in1");
    lgraph = connectLayers(lgraph,"res4b14_relu","res4b15_branch2a");
    lgraph = connectLayers(lgraph,"res4b14_relu","res4b15/in2");
    lgraph = connectLayers(lgraph,"bn4b15_branch2c","res4b15/in1");
    lgraph = connectLayers(lgraph,"res4b15_relu","res4b16_branch2a");
    lgraph = connectLayers(lgraph,"res4b15_relu","res4b16/in2");
    lgraph = connectLayers(lgraph,"bn4b16_branch2c","res4b16/in1");
    lgraph = connectLayers(lgraph,"res4b16_relu","res4b17_branch2a");
    lgraph = connectLayers(lgraph,"res4b16_relu","res4b17/in2");
    lgraph = connectLayers(lgraph,"bn4b17_branch2c","res4b17/in1");
    lgraph = connectLayers(lgraph,"res4b17_relu","res4b18_branch2a");
    lgraph = connectLayers(lgraph,"res4b17_relu","res4b18/in2");
    lgraph = connectLayers(lgraph,"bn4b18_branch2c","res4b18/in1");
    lgraph = connectLayers(lgraph,"res4b18_relu","res4b19_branch2a");
    lgraph = connectLayers(lgraph,"res4b18_relu","res4b19/in2");
    lgraph = connectLayers(lgraph,"bn4b19_branch2c","res4b19/in1");
    lgraph = connectLayers(lgraph,"res4b19_relu","res4b20_branch2a");
    lgraph = connectLayers(lgraph,"res4b19_relu","res4b20/in2");
    lgraph = connectLayers(lgraph,"bn4b20_branch2c","res4b20/in1");
    lgraph = connectLayers(lgraph,"res4b20_relu","res4b21_branch2a");
    lgraph = connectLayers(lgraph,"res4b20_relu","res4b21/in2");
    lgraph = connectLayers(lgraph,"bn4b21_branch2c","res4b21/in1");
    lgraph = connectLayers(lgraph,"res4b21_relu","res4b22_branch2a");
    lgraph = connectLayers(lgraph,"res4b21_relu","res4b22/in2");
    lgraph = connectLayers(lgraph,"bn4b22_branch2c","res4b22/in1");
    lgraph = connectLayers(lgraph,"res4b22_relu","res5a_branch1");
    lgraph = connectLayers(lgraph,"res4b22_relu","res5a_branch2a");
    lgraph = connectLayers(lgraph,"bn5a_branch1","res5a/in2");
    lgraph = connectLayers(lgraph,"bn5a_branch2c","res5a/in1");
    lgraph = connectLayers(lgraph,"res5a_relu","res5b_branch2a");
    lgraph = connectLayers(lgraph,"res5a_relu","res5b/in2");
    lgraph = connectLayers(lgraph,"bn5b_branch2c","res5b/in1");
    lgraph = connectLayers(lgraph,"res5b_relu","res5c_branch2a");
    lgraph = connectLayers(lgraph,"res5b_relu","res5c/in2");
    lgraph = connectLayers(lgraph,"bn5c_branch2c","res5c/in1");

    [net, traininfo] = trainNetwork(augimdsTrain,lgraph,opts);

    %save('net.mat','net');
    save(strcat("traininfo_",string(class_count),".mat"), "traininfo");

    augimdsTest = augmentedImageDatastore([224 224 3],imdsTest,"ColorPreprocessing","gray2rgb");

    YPred = classify(net,augimdsTest);

    labels = categories(imdsTest.Labels);

    confusion_matrix = confusionmat(imdsTest.Labels,YPred);

    save(strcat("labels_",string(class_count),".mat"), "labels");
    save(strcat("cm_",string(class_count),".mat"), "confusion_matrix");
end

