# COVID-19 Data Exploration Using MySQL

## 📌 Project Overview

This project is my first SQL portfolio project, created to practice and demonstrate data exploration skills using **MySQL**.

The project analyzes COVID-19 data related to cases, deaths, population, and vaccinations. The analysis begins with fundamental SQL exploration and continues with more advanced techniques such as **JOINs, Common Table Expressions (CTEs), Window Functions, Temporary Tables, and Views**.

In addition to the core analysis, I developed several additional analyses focusing on **Indonesia, Southeast Asia, global monthly COVID-19 trends, infection rates, death counts, and vaccination progress**.

---

## 🎯 Project Objectives

The main objectives of this project are to:

* Explore global COVID-19 cases and deaths.
* Calculate the percentage of confirmed cases that resulted in recorded deaths.
* Measure COVID-19 cases relative to population.
* Identify countries with the highest infection rates.
* Identify countries with the highest recorded death counts.
* Analyze global COVID-19 trends over time.
* Combine COVID-19 deaths and vaccination datasets using `JOIN`.
* Calculate cumulative vaccination doses using Window Functions.
* Compare COVID-19 conditions across Southeast Asian countries.
* Analyze the development of COVID-19 cases and vaccinations in Indonesia.

---

## 📂 Dataset

The project uses two main datasets:

* `coviddeaths_clean`
* `covidvaccinations_clean`

The datasets contain information such as:

* Continent
* Country
* Date
* Population
* Total cases
* New cases
* Total deaths
* New deaths
* Testing data
* Vaccination data

Before performing the analysis, the datasets were cleaned and adjusted for use in MySQL, including:

* Converting date values into proper `DATETIME` format.
* Converting empty values into SQL `NULL`.
* Adjusting several data types.
* Adapting SQL Server syntax from the learning material into MySQL-compatible syntax.

---

## 🛠️ Tools Used

* **MySQL Workbench**
* **GitHub**

---

## 🧠 SQL Skills Demonstrated

This project uses several SQL concepts, including:

* `SELECT`
* `WHERE`
* `ORDER BY`
* `GROUP BY`
* `LIMIT`
* Aggregate Functions

  * `SUM()`
  * `MAX()`
* `CAST()`
* `ROUND()`
* `NULLIF()`
* NULL handling
* `JOIN`
* Common Table Expressions (`CTE`)
* Window Functions
* `PARTITION BY`
* Rolling / cumulative calculations
* Temporary Tables
* Views
* Date functions

  * `DATE_FORMAT()`

---

# 🔍 Core Data Exploration

## 1. Total Cases vs Total Deaths

This analysis calculates the percentage of reported COVID-19 cases that resulted in recorded deaths.

```sql
SELECT 
    location,
    `date`,
    total_cases,
    total_deaths,
    (total_deaths / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM PortofolioProject.coviddeaths_clean
WHERE location = 'United States'
ORDER BY location, `date`;
```

---

## 2. Total Cases vs Population

This analysis measures the percentage of a country's population represented by reported COVID-19 cases.

```sql
SELECT 
    location,
    `date`,
    total_cases,
    population,
    (total_cases / NULLIF(population, 0)) * 100 AS PercentPopulationInfected
FROM PortofolioProject.coviddeaths_clean
WHERE location = 'United States'
ORDER BY location, `date`;
```

---

## 3. Countries with the Highest Infection Rate

Countries are compared based on the maximum cumulative cases relative to their population.

```sql
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(total_cases / NULLIF(population, 0)) * 100 AS PercentPopulationInfected
FROM PortofolioProject.coviddeaths_clean
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;
```

---

## 4. Countries with the Highest Death Count

```sql
SELECT 
    location,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM PortofolioProject.coviddeaths_clean
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;
```

---

## 5. Global COVID-19 Numbers by Date

```sql
SELECT 
    `date`,
    SUM(CAST(new_cases AS SIGNED)) AS TotalCases,
    SUM(CAST(new_deaths AS SIGNED)) AS TotalDeaths,
    (
        SUM(CAST(new_deaths AS SIGNED))
        / NULLIF(SUM(CAST(new_cases AS SIGNED)), 0)
    ) * 100 AS DeathPercentage
FROM PortofolioProject.coviddeaths_clean
WHERE continent IS NOT NULL
GROUP BY `date`
ORDER BY `date`;
```

---

# 💉 Vaccination Analysis

The deaths and vaccination datasets were combined using a `JOIN`.

A Window Function was then used to calculate cumulative vaccination doses for each country.

```sql
SELECT 
    dea.continent,
    dea.location,
    dea.`date`,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED))
        OVER (
            PARTITION BY dea.location
            ORDER BY dea.`date`
        ) AS RollingVaccinationDoses
FROM PortofolioProject.coviddeaths_clean AS dea
JOIN PortofolioProject.covidvaccinations_clean AS vac
    ON dea.location = vac.location
    AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.`date`;
```

The project also applies:

* Common Table Expressions
* Temporary Tables
* Views

to demonstrate different ways of storing and reusing calculated results.

---

# 📊 Original Analysis

In addition to the core SQL exploration, I created several additional analyses to explore the dataset independently.

---

## Original Analysis 1 — COVID-19 Trend in Indonesia

This analysis tracks:

* Total cases
* New cases
* Total deaths
* Infection percentage
* Deaths-to-cases percentage

for Indonesia over time.

The early dataset shows Indonesia beginning with only a few reported cases in March 2020, followed by rapid case growth during the early stage of the pandemic.

---

## Original Analysis 2 — Top 10 Countries by Infection Rate

Based on the available dataset period, the countries with the highest infection rates included:

| Rank | Country       | Population Infected |
| ---- | ------------- | ------------------: |
| 1    | Andorra       |              17.13% |
| 2    | Montenegro    |              15.51% |
| 3    | Czechia       |              15.23% |
| 4    | San Marino    |              14.93% |
| 5    | Slovenia      |              11.56% |
| 6    | Luxembourg    |              10.74% |
| 7    | Bahrain       |              10.40% |
| 8    | Serbia        |              10.13% |
| 9    | United States |               9.77% |
| 10   | Israel        |               9.69% |

This analysis shows that the countries with the largest number of total cases were not necessarily the countries with the highest infection rate relative to population.

---

## Original Analysis 3 — Top 10 Countries by Total Deaths

Within the dataset period, the countries with the highest cumulative recorded deaths included:

| Rank | Country        | Total Deaths |
| ---- | -------------- | -----------: |
| 1    | United States  |      576,232 |
| 2    | Brazil         |      403,781 |
| 3    | Mexico         |      216,907 |
| 4    | India          |      211,853 |
| 5    | United Kingdom |      127,775 |
| 6    | Italy          |      120,807 |
| 7    | Russia         |      108,290 |
| 8    | France         |      104,675 |
| 9    | Germany        |       83,097 |
| 10   | Spain          |       78,216 |

---

## Original Analysis 4 — Global Monthly COVID-19 Trend

Monthly COVID-19 cases and deaths were aggregated using `DATE_FORMAT()`.

The analysis shows substantial growth in reported global cases throughout 2020.

For example:

* March 2020: approximately **789 thousand new cases**
* October 2020: approximately **12.1 million new cases**
* November 2020: approximately **17.3 million new cases**
* December 2020: approximately **19.3 million new cases**

The monthly deaths-to-cases ratio was particularly high during the early stage of the pandemic, reaching approximately **8.02% in April 2020**, before declining in later months.

> The deaths-to-cases ratio should not be interpreted as an individual probability of dying because deaths recorded in one month may relate to infections reported during an earlier period.

---

## Original Analysis 5 — Southeast Asia Comparison

COVID-19 outcomes were compared across selected Southeast Asian countries.

| Country     | Infection Rate | Deaths-to-Cases Ratio |
| ----------- | -------------: | --------------------: |
| Malaysia    |          1.26% |                 0.37% |
| Singapore   |          1.05% |                 0.05% |
| Philippines |          0.95% |                 1.66% |
| Indonesia   |          0.61% |                 2.73% |
| Myanmar     |          0.26% |                 2.25% |
| Thailand    |          0.09% |                 0.31% |
| Cambodia    |          0.08% |                 0.69% |
| Brunei      |          0.05% |                 1.34% |
| Laos        |          0.01% |                   N/A |
| Vietnam     |         <0.01% |                 1.20% |

Malaysia recorded the highest infection rate among the selected Southeast Asian countries in this dataset.

However, Indonesia recorded the highest deaths-to-cases ratio at approximately **2.73%**.

This demonstrates that a higher infection rate did not necessarily correspond to a higher deaths-to-cases ratio.

---

## Original Analysis 6 — Vaccination Progress in Indonesia

Vaccination progress in Indonesia was analyzed using a cumulative Window Function.

The first non-null vaccination record returned by this dataset for Indonesia appears on **25 January 2021**, with:

* **12,717 new vaccination doses**
* **12,717 cumulative recorded doses**

The cumulative number of recorded doses increased to approximately:

**774,207 doses by 7 February 2021**

This represented approximately:

**0.28 recorded vaccination doses per 100 people**

at that point in the dataset.

The metric is described as **vaccination doses per 100 people**, rather than percentage of unique people vaccinated, because an individual may receive more than one vaccine dose.

---

# 💡 Key Findings

Several findings emerged from the analysis:

* **Andorra** recorded the highest infection rate in the dataset at approximately **17.13% of its population**.
* The **United States** recorded the highest cumulative death count within the analyzed dataset period, followed by Brazil and Mexico.
* Global reported COVID-19 cases increased substantially throughout 2020, reaching approximately **19.3 million new cases in December 2020**.
* The global monthly deaths-to-cases ratio was highest during the early pandemic period, reaching approximately **8.02% in April 2020** before declining.
* Among the Southeast Asian countries analyzed, **Malaysia** recorded the highest infection rate at approximately **1.26%**.
* **Indonesia** recorded an infection rate of approximately **0.61%**, but showed the highest deaths-to-cases ratio among the selected Southeast Asian countries at approximately **2.73%**.
* Indonesia's cumulative recorded vaccination doses increased consistently during the early vaccination period represented in the dataset.

---

# 📁 Repository Structure

```text
COVID-19-SQL-Data-Exploration/
│
├── README.md
├── covid19_sql_data_exploration.sql
│
├── data/
│   ├── CovidDeaths.csv
│   └── CovidVaccinations.csv
│
└── images/
    ├── top_infection_rate.png
    ├── top_death_count.png
    ├── global_monthly_trend.png
    ├── southeast_asia_comparison.png
    └── indonesia_vaccination_progress.png
```

---

# 🚀 How to Run the Project

1. Install **MySQL** and **MySQL Workbench**.
2. Create a database for the project.
3. Import the COVID-19 deaths and vaccination datasets.
4. Ensure the date columns use an appropriate date or datetime data type.
5. Run the queries contained in:

```text
covid19_sql_data_exploration.sql
```

6. Execute each analysis section separately to explore the results.

---

# 📈 Future Improvements

Possible next steps for this project include:

* Creating a dashboard using **Power BI** or **Tableau**.
* Visualizing global COVID-19 trends.
* Building interactive country comparisons.
* Analyzing vaccination growth across Southeast Asian countries.
* Comparing infection and vaccination trends.
* Developing additional SQL analyses using more advanced Window Functions.

---

# 🙏 Acknowledgements

This project was initially inspired by the **COVID-19 SQL Data Exploration portfolio project by Alex The Analyst**.

The original learning material uses SQL Server. For this project, the analysis was adapted to **MySQL**, including adjustments to:

* Date handling
* Data types
* `CAST()` syntax
* NULL handling
* Temporary Tables
* Views
* Other MySQL-specific syntax

Additional analyses were developed to explore:

* Indonesia's COVID-19 trend
* Top infection rates
* Top death counts
* Global monthly trends
* Southeast Asian countries
* Indonesia's vaccination progress

This project represents my learning process in applying SQL concepts to a real-world dataset and developing my first data analytics portfolio project.

---

⭐ If you found this project useful, feel free to explore the SQL queries and analysis in this repository.
