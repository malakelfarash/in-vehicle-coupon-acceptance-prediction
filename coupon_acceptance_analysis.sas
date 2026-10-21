/* Import the Data */
FILENAME REFFILE '/home/u64508924/DS Tools Project/in-vehicle-coupon-recommendation.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.coupons;
	GETNAMES=YES;
RUN;

/* Understand the Data */
PROC CONTENTS DATA=WORK.coupons;
RUN;

%LET num_vars = temperature age has_children toCoupon_GEQ5min toCoupon_GEQ15min
                toCoupon_GEQ25min direction_same direction_opp Y;

%LET cat_vars = destination passanger weather time coupon expiration
                gender maritalStatus education occupation income car
                Bar CoffeeHouse CarryAway RestaurantLessThan20 Restaurant20To50;

PROC MEANS DATA=WORK.coupons N NMISS MEAN MEDIAN STD MIN MAX;
    VAR &num_vars.;
    TITLE "Descriptive Statistics for Numeric Variables";
RUN;

PROC FREQ DATA=WORK.coupons;
    TABLES &cat_vars. / MISSING;
    TITLE "Frequency Distributions of Categorical Variables";
RUN;

PROC SQL;
	TITLE "Missing Values Count";
	SELECT 
        NMISS(age) AS missing_age,
        NMISS(car) AS missing_car,
        NMISS(Bar) AS missing_Bar,
        NMISS(CoffeeHouse) AS missing_CoffeeHouse,
        NMISS(CarryAway) AS missing_CarryAway,
        NMISS(RestaurantLessThan20) AS missing_RestaurantLessThan20,
        NMISS(Restaurant20To50) AS missing_Restaurant20To50
	FROM WORK.coupons;
QUIT;

/* Sort and remove duplicates, saving to a new dataset */
PROC SORT DATA=WORK.coupons OUT=WORK.coupons_nodup NODUPKEY DUPOUT=WORK.duplicates;
    BY _ALL_;
RUN;

/* See how many duplicates were found */
PROC SQL;
    TITLE "Duplicate Rows Count";
    SELECT 
        (SELECT COUNT(*) FROM WORK.coupons) AS original_count,
        (SELECT COUNT(*) FROM WORK.coupons_nodup) AS after_dedup_count,
        (SELECT COUNT(*) FROM WORK.duplicates) AS duplicate_count
    FROM WORK.coupons (OBS=1);
QUIT;

/* Visualizations */
/* Target variable */
/* Visualization 1: Coupon Acceptance Rate */
PROC GCHART DATA=WORK.coupons_nodup;
    PIE Y / DISCRETE
            VALUE=INSIDE
            PERCENT=INSIDE
            SLICE=OUTSIDE;
    TITLE "Visualization 1: Coupon Acceptance Rate (Y=1 Accepted, Y=0 Rejected)";
RUN;
QUIT;

/* Contextual Featues (situation when offered) */
/* Visualization 2: Coupon Type vs Acceptance */
PROC SGPLOT DATA=WORK.coupons_nodup;
    VBAR coupon / GROUP=Y GROUPDISPLAY=CLUSTER STAT=PERCENT;
    TITLE "Visualization 2: Coupon Type vs Acceptance Rate";
    XAXIS LABEL="Coupon Type";
    YAXIS LABEL="Percentage (%)";
    KEYLEGEND / TITLE="Y: 0=Rejected  1=Accepted";
RUN;

/* Visualization 3: Weather vs Acceptance */
PROC SGPLOT DATA=WORK.coupons_nodup;
    VBAR weather / GROUP=Y GROUPDISPLAY=CLUSTER STAT=PERCENT;
    TITLE "Visualization 3: Weather vs Acceptance Rate";
    XAXIS LABEL="Weather";
    YAXIS LABEL="Percentage (%)";
    KEYLEGEND / TITLE="Y: 0=Rejected  1=Accepted";
RUN;

/* Visualization 4: Time of Day vs Acceptance */
PROC SGPLOT DATA=WORK.coupons_nodup;
    VBAR time / GROUP=Y GROUPDISPLAY=CLUSTER STAT=PERCENT;
    TITLE "Visualization 4: Time of Day vs Acceptance Rate";
    XAXIS LABEL="Time of Day";
    YAXIS LABEL="Percentage (%)";
    KEYLEGEND / TITLE="Y: 0=Rejected  1=Accepted";
RUN;

/* Visualization 5: Temperature vs Acceptance */
PROC SGPLOT DATA=WORK.coupons_nodup;
    VBAR temperature / GROUP=Y GROUPDISPLAY=CLUSTER STAT=PERCENT;
    TITLE "Visualization 5: Temperature vs Acceptance Rate";
    XAXIS LABEL="Temperature (F)";
    YAXIS LABEL="Percentage (%)";
    KEYLEGEND / TITLE="Y: 0=Rejected  1=Accepted";
RUN;

/* Visualization 6: Destination vs Acceptance */
PROC SGPLOT DATA=WORK.coupons_nodup;
    VBAR destination / GROUP=Y GROUPDISPLAY=CLUSTER STAT=PERCENT;
    TITLE "Visualization 6: Destination vs Acceptance Rate";
    XAXIS LABEL="Destination";
    YAXIS LABEL="Percentage (%)";
    KEYLEGEND / TITLE="Y: 0=Rejected  1=Accepted";
RUN;

/* Visualization 7: Passenger Type vs Acceptance */
PROC SGPLOT DATA=WORK.coupons_nodup;
    VBAR passanger / GROUP=Y GROUPDISPLAY=CLUSTER STAT=PERCENT;
    TITLE "Visualization 7: Passenger Type vs Acceptance Rate";
    XAXIS LABEL="Passenger";
    YAXIS LABEL="Percentage (%)";
    KEYLEGEND / TITLE="Y: 0=Rejected  1=Accepted";
RUN;

/* Visualization 8: Coupon Expiration vs Acceptance */
PROC SGPLOT DATA=WORK.coupons_nodup;
    VBAR expiration / GROUP=Y GROUPDISPLAY=CLUSTER STAT=PERCENT;
    TITLE "Visualization 8: Coupon Expiration vs Acceptance Rate";
    XAXIS LABEL="Expiration (2h = 2 hours, 1d = 1 day)";
    YAXIS LABEL="Percentage (%)";
    KEYLEGEND / TITLE="Y: 0=Rejected  1=Accepted";
RUN;

/* Demographic Features (who the driver is) */
/* Visualization 9: Age vs Acceptance */
PROC SGPLOT DATA=WORK.coupons_nodup;
    VBAR age / GROUP=Y GROUPDISPLAY=CLUSTER STAT=PERCENT;
    TITLE "Visualization 9: Age Group vs Acceptance Rate";
    XAXIS LABEL="Age";
    YAXIS LABEL="Percentage (%)";
    KEYLEGEND / TITLE="Y: 0=Rejected  1=Accepted";
RUN;

/* Visualization 10: Income vs Acceptance */
PROC SGPLOT DATA=WORK.coupons_nodup;
    HBAR income / GROUP=Y GROUPDISPLAY=CLUSTER STAT=PERCENT;
    TITLE "Visualization 10: Income Level vs Acceptance Rate";
    YAXIS LABEL="Income";
    XAXIS LABEL="Percentage (%)";
    KEYLEGEND / TITLE="Y: 0=Rejected  1=Accepted";
RUN;

/* Distance / Direction Features */
/* Visualization 11: Direction Same vs Acceptance */
PROC SGPLOT DATA=WORK.coupons_nodup;
    VBAR direction_same / GROUP=Y GROUPDISPLAY=CLUSTER STAT=PERCENT;
    TITLE "Visualization 11: Same Direction as Coupon vs Acceptance";
    XAXIS LABEL="Direction Same (0=No, 1=Yes)";
    YAXIS LABEL="Percentage (%)";
    KEYLEGEND / TITLE="Y: 0=Rejected  1=Accepted";
RUN;

/* Visualization 12: Distance >=25 min vs Acceptance */
PROC SGPLOT DATA=WORK.coupons_nodup;
    VBAR toCoupon_GEQ25min / GROUP=Y GROUPDISPLAY=CLUSTER STAT=PERCENT;
    TITLE "Visualization 12: Coupon Destination >=25 min Away vs Acceptance";
    XAXIS LABEL=">=25 min away (0=No, 1=Yes)";
    YAXIS LABEL="Percentage (%)";
    KEYLEGEND / TITLE="Y: 0=Rejected  1=Accepted";
RUN;

/* Correlation Matrix of Numeric Variables */
PROC CORR DATA=WORK.coupons_nodup;
    VAR &num_vars.;
    TITLE "Pearson Correlation Matrix of Numeric Variables";
RUN;

/* Univariate Analysis of Numeric Variables */
PROC UNIVARIATE DATA=WORK.coupons_nodup NORMAL;
    VAR temperature age;
    TITLE "Univariate Analysis of Numeric Variables";
RUN;

/* Summary Tables*/
/* Average Acceptance Rate Summary by Coupon Type */
PROC MEANS DATA=WORK.coupons_nodup MEAN N;
    CLASS coupon;
    VAR Y;
    TITLE "Average Acceptance Rate by Coupon Type";
    OUTPUT OUT=WORK.coupon_accept_rate MEAN=Accept_Rate N=Total;
RUN;

/* Average Acceptance Rate by Passenger Type and Coupon Type */
PROC MEANS DATA=WORK.coupons_nodup MEAN N;
    CLASS passanger coupon;
    VAR Y;
    TITLE "Acceptance Rate by Passenger Type and Coupon Type";
RUN;

/* Average Acceptance Rate by Expiration and Coupon Type */
PROC MEANS DATA=WORK.coupons_nodup MEAN N;
    CLASS expiration coupon;
    VAR Y;
    TITLE "Acceptance Rate by Expiration and Coupon Type";
RUN;

/* Average Acceptance Rate by Weather and Time combined */
PROC MEANS DATA=WORK.coupons_nodup MEAN N;
    CLASS weather time;
    VAR Y;
    TITLE "Average Acceptance Rate by Weather x Time of Day";
RUN;

/* Outlier Detection */
/* IQR Method (standard statistical approach) */
PROC MEANS DATA=WORK.coupons_nodup Q1 Q3 QRANGE NOPRINT;
	VAR temperature age;
    OUTPUT OUT=WORK.iqr_stats
    Q1=temp_Q1 age_Q1
    Q3=temp_Q3 age_Q3
    QRANGE=temp_IQR age_IQR;
RUN;

/* Flag outliers using IQR bounds */
DATA WORK.coupons_flagged;
    IF _N_ = 1 THEN SET WORK.iqr_stats;
    SET WORK.coupons_nodup;

    /* Temperature outlier bounds */
    temp_lower = temp_Q1 - 1.5 * temp_IQR;
    temp_upper = temp_Q3 + 1.5 * temp_IQR;
    temp_outlier = (temperature < temp_lower OR temperature > temp_upper);

    /* Age outlier bounds */
    age_lower = age_Q1 - 1.5 * age_IQR;
    age_upper = age_Q3 + 1.5 * age_IQR;
    age_outlier = (age < age_lower OR age > age_upper);
RUN;

/* Count how many outliers exist */
PROC FREQ DATA=WORK.coupons_flagged;
    TABLES temp_outlier age_outlier;
    TITLE "Outlier Count: IQR Method (1 = Outlier)";
RUN;

/* Using Box plots (best visual for outliers) */
/* Box plot (Temperature) */
PROC SGPLOT DATA=WORK.coupons_nodup;
    VBOX temperature / CATEGORY=Y FILLATTRS=(COLOR=lightblue)
                       WHISKERATTRS=(COLOR=navy)
                       OUTLIERATTRS=(COLOR=red SYMBOL=CircleFilled SIZE=5);
    TITLE "Temperature Distribution by Acceptance — Box Plot";
    XAXIS LABEL="Y (0=Rejected, 1=Accepted)";
    YAXIS LABEL="Temperature (F)";
RUN;

/* Box plot (Age) */
PROC SGPLOT DATA=WORK.coupons_nodup;
    VBOX age / CATEGORY=Y FILLATTRS=(COLOR=lightyellow)
               WHISKERATTRS=(COLOR=darkbrown)
               OUTLIERATTRS=(COLOR=red SYMBOL=CircleFilled SIZE=5);
    TITLE "Age Distribution by Acceptance — Box Plot";
    XAXIS LABEL="Y (0=Rejected, 1=Accepted)";
    YAXIS LABEL="Age";
RUN;

/* Data Cleaning Report (Before & After) */
/* 1. Initial Missing Values (Numeric Variables) */
TITLE "1. Initial Missing Values Report (Numeric Variables)";

/* Check number of missing values in numeric columns */
PROC MEANS DATA=WORK.coupons_nodup N NMISS MIN MAX;
    VAR age temperature;
RUN;


/* 2. Missing Percentage (All Variables) */
/* Create formats to label missing vs non-missing values */
PROC FORMAT;
    VALUE $missfmt ' '='Missing' other='Not Missing';
    VALUE missfmt .='Missing' other='Not Missing';
RUN;

TITLE "2. Missing Percentage Across All Variables";

/* Display missing distribution for all columns */
PROC FREQ DATA=WORK.coupons_nodup;
    FORMAT _CHAR_ $missfmt. _NUMERIC_ missfmt.;
    TABLES _ALL_ / MISSING NOCUM;
RUN;

/* Drop 'car' variable due to extremely high missing percentage */
DATA WORK.prep; 
    SET WORK.coupons_nodup; 
    DROP car; 
RUN;

/* Train / Test Split(80/20) */
TITLE "3. Train/Test Split (80/20)";

/* Perform simple random sampling to split data */
PROC SURVEYSELECT DATA=WORK.prep 
    OUT=WORK.split_results 
    METHOD=SRS 
    SAMPRATE=0.80 
    OUTALL 
    SEED=12345;
RUN;

/* Separate selected (train) and non-selected (test) observations */
DATA WORK.train WORK.test;
    SET WORK.split_results;
    IF Selected THEN OUTPUT WORK.train;
    ELSE OUTPUT WORK.test;
RUN;

/* Verify split ratio */
PROC FREQ DATA=WORK.split_results;
    TABLES Selected;
RUN;

/* Numerical Imputation */
/* Compute mean of 'age' using TRAIN data only */
PROC MEANS DATA=WORK.train NOPRINT;
    VAR age;
    OUTPUT OUT=WORK.age_mean MEAN=m_age;
RUN;

/* Apply mean imputation to TRAIN dataset */
DATA WORK.train_final;
    IF _N_ = 1 THEN SET WORK.age_mean;
    SET WORK.train;
    IF age = . THEN age = m_age;
    age = ROUND(age,1);
    DROP m_age _TYPE_ _FREQ_;
RUN;

/* Apply same mean (from TRAIN) to TEST dataset */
DATA WORK.test_final;
    IF _N_ = 1 THEN SET WORK.age_mean;
    SET WORK.test;
    IF age = . THEN age = m_age;
    age = ROUND(age,1);
    DROP m_age _TYPE_ _FREQ_;
RUN;

/* Categorical Cleaning & Standardization */
%MACRO clean_subset(d_in, d_out);

DATA &d_out.;
    /* Expand column length to prevent truncation */
    LENGTH Bar CoffeeHouse CarryAway RestaurantLessThan20 Restaurant20To50 $30;
    SET &d_in.;

    /* Replace missing categorical values with default values */
    IF Bar = "" THEN Bar = "never";
    IF CoffeeHouse = "" THEN CoffeeHouse = "less1";
    IF CarryAway = "" THEN CarryAway = "1";
    IF RestaurantLessThan20 = "" THEN RestaurantLessThan20 = "1~3";
    IF Restaurant20To50 = "" THEN Restaurant20To50 = "les";

    /* Standardize category labels */
    ARRAY freq_cols[5] Bar CoffeeHouse CarryAway RestaurantLessThan20 Restaurant20To50;
    
    DO i = 1 TO 5;
        Check_Val = lowcase(strip(freq_cols[i]));

        IF Check_Val IN ('never','nev','n','') THEN freq_cols[i] = 'Never';
        ELSE IF Check_Val IN ('less1','les','l') THEN freq_cols[i] = 'Less than once';
        ELSE IF Check_Val IN ('1~3','1') THEN freq_cols[i] = '1 to 3 times';
        ELSE IF Check_Val IN ('4~8','4') THEN freq_cols[i] = '4 to 8 times';
        ELSE IF Check_Val IN ('gt8','g') THEN freq_cols[i] = 'More than 8 times';
    END;

    DROP i Check_Val;
RUN;

%MEND;

/* Apply cleaning macro to both datasets */
%clean_subset(WORK.train_final, WORK.train_final_clean);
%clean_subset(WORK.test_final, WORK.test_final_clean);

/* Final Validation */
/* Check missing values after cleaning */
TITLE "4. Final Validation - Missing Values (After Cleaning)";

PROC MEANS DATA=WORK.train_final_clean NMISS N;
    VAR age;
RUN;

PROC MEANS DATA=WORK.test_final_clean NMISS N;
    VAR age;
RUN;


/* Check final categorical distributions */
TITLE "5. Final Frequency Distribution (Train Set)";

PROC FREQ DATA=WORK.train_final_clean;
    TABLES Bar CoffeeHouse CarryAway RestaurantLessThan20 Restaurant20To50 / NOCUM;
    FORMAT Bar CoffeeHouse CarryAway RestaurantLessThan20 Restaurant20To50 $30.;
RUN;

TITLE "6. Final Frequency Distribution (Test Set)";

PROC FREQ DATA=WORK.test_final_clean;
    TABLES Bar CoffeeHouse CarryAway RestaurantLessThan20 Restaurant20To50 / NOCUM;
    FORMAT Bar CoffeeHouse CarryAway RestaurantLessThan20 Restaurant20To50 $30.;
RUN;

/*Feature Engineering & Data Preparatin For Logistic Regression */
/* 1. Create a Macro for Feature Engineering to apply to the Train and Test sets separately */
%MACRO do_feature_engineering(d_in, d_out);

DATA &d_out.;
    SET &d_in.; 

    /* Feature A: Total_Distance_Level */
    Total_Distance_Level = sum(toCoupon_GEQ5min, toCoupon_GEQ15min, toCoupon_GEQ25min);

    /* Feature B: Coupon_Habit_Match */
    Coupon_Habit_Match = 0;
    IF (coupon = 'Coffee House' AND CoffeeHouse IN ('1 to 3 times', '4 to 8 times', 'More than 8 times')) THEN Coupon_Habit_Match = 1;
    ELSE IF (coupon = 'Bar' AND Bar IN ('1 to 3 times', '4 to 8 times', 'More than 8 times')) THEN Coupon_Habit_Match = 1;
    ELSE IF (coupon = 'Carry out & Take away' AND CarryAway IN ('1 to 3 times', '4 to 8 times', 'More than 8 times')) THEN Coupon_Habit_Match = 1;
    ELSE IF (coupon = 'Restaurant(<20)' AND RestaurantLessThan20 IN ('1 to 3 times', '4 to 8 times', 'More than 8 times')) THEN Coupon_Habit_Match = 1;
    ELSE IF (coupon = 'Restaurant(20-50)' AND Restaurant20To50 IN ('1 to 3 times', '4 to 8 times', 'More than 8 times')) THEN Coupon_Habit_Match = 1;

    /* Feature C: Companion_Logic */
    Companion_Logic = 1; 
    IF passanger = 'Kid(s)' AND coupon = 'Bar' THEN Companion_Logic = 0;

    /* Feature D: Bad_Weather_Home_Flag */
    Bad_Weather_Home_Flag = 0;
    IF weather IN ('Rainy', 'Snowy') AND destination = 'Home' THEN Bad_Weather_Home_Flag = 1;

    /* Feature E: Urgency_Score */
    IF expiration = '2h' AND toCoupon_GEQ25min = 1 THEN Urgency_Score = 1; 
    ELSE IF expiration = '2h' AND toCoupon_GEQ15min = 1 THEN Urgency_Score = 2;
    ELSE IF expiration = '2h' AND toCoupon_GEQ5min = 1 THEN Urgency_Score = 3;
    ELSE IF expiration = '1d' THEN Urgency_Score = 4;
    ELSE Urgency_Score = 0;

    /* 2. Encoding Categorical Variables */
    ARRAY freq_chars[*] Bar CoffeeHouse CarryAway RestaurantLessThan20 Restaurant20To50;
    ARRAY freq_nums[*] Bar_num CoffeeHouse_num CarryAway_num RestLess20_num Rest20To50_num;
    DO i = 1 TO DIM(freq_chars);
        IF freq_chars[i] = 'Never' THEN freq_nums[i] = 0;
        ELSE IF freq_chars[i] = 'Less than once' THEN freq_nums[i] = 1;
        ELSE IF freq_chars[i] = '1 to 3 times' THEN freq_nums[i] = 2;
        ELSE IF freq_chars[i] = '4 to 8 times' THEN freq_nums[i] = 3;
        ELSE IF freq_chars[i] = 'More than 8 times' THEN freq_nums[i] = 4;
        ELSE freq_nums[i] = .;
    END;
    DROP i;

    /* 3. Dropping Redundant Columns */
    DROP toCoupon_GEQ5min toCoupon_GEQ15min toCoupon_GEQ25min;
RUN;

%MEND;

/* Apply the macro to the Train and Test sets */
%do_feature_engineering(WORK.train_final_clean, WORK.train_engineered);
%do_feature_engineering(WORK.test_final_clean, WORK.test_engineered);

/* 4. Scaling Numeric Features */
/* Scale the Train data and save the statistics (Mean & STD) in a file named scale_stats */
PROC STDIZE DATA=WORK.train_engineered OUT=WORK.train_ready OUTSTAT=WORK.scale_stats METHOD=STD;
    VAR temperature age; 
RUN;

/* Use the statistics derived from the Train set to scale the Test set */
PROC STDIZE DATA=WORK.test_engineered OUT=WORK.test_ready METHOD=IN(WORK.scale_stats);
    VAR temperature age; 
RUN;

/* Validation Report for the Final Prepared Dataset */
PROC PRINT DATA=WORK.train_ready (OBS=20);
    VAR age temperature Total_Distance_Level Coupon_Habit_Match Urgency_Score Bar_num CoffeeHouse_num;
    TITLE "Final Standardized TRAIN Dataset Ready for Modeling";
RUN;


/* Model Building */
TITLE "7. Logistic Regression Model - Training Phase";

/* We use the Train dataset to build the model */
proc logistic data=WORK.train_ready plots(only maxpoints= none)=(roc);
     /* Categorical variables that should be treated as factors */
     class gender coupon weather / param=ref; 
     
     /* The Model: Y is our target (Accept/Reject) */
     /* We use the engineered features: Urgency, Habit_Match, etc. */
     model Y(event='1') = age temperature Total_Distance_Level 
                         Urgency_Score Coupon_Habit_Match CoffeeHouse_num 
                         Bar_num CarryAway_num / selection=stepwise; 
     
     /* Save the model and predict on the Test set */
     score data=WORK.test_ready out=work.final_predictions;
run;

/* Explaining the Model (Visual Insights) */
TITLE "8. Model Evaluation - Probability Distribution";

/* Visualizing the predicted probabilities to see how confident the model is */
proc sgplot data=work.final_predictions;
     density P_1 / group=Y;
     title "Distribution of Predicted Probabilities by Actual Outcome";
     xaxis label="Predicted Probability of Acceptance";
run;

/* Model Accuracy */
TITLE "9. Final Model Accuracy on Test Data";

/* Comparing Actual Y vs Predicted Y */
proc freq data=work.final_predictions;
     tables Y * I_Y / nocol norow nopercent;
     title "Confusion Matrix (Test Set)";
     run;

proc discrim data=WORK.train_ready method=npar k=5 
             testdata=WORK.test_ready testout=work.knn_results;
    class Y;
    var age temperature Total_Distance_Level Urgency_Score 
        Coupon_Habit_Match CoffeeHouse_num Bar_num CarryAway_num;
run;


proc freq data=work.knn_results;
    tables Y * _into_ / senspec;
    title "Performance of KNN Model (K=5)";
run;


proc sgplot data=work.knn_results;
    title "KNN Model: Predicted vs Actual Agreement";
    vbar Y / group=_into_ groupdisplay=cluster 
             fillattrs=(transparency=0.3) datalabel;
    xaxis label="Actual Outcome (0=Refuse, 1=Accept)";
    yaxis label="Count of Customers";
    keylegend / title="Model Predicted As:";
run;