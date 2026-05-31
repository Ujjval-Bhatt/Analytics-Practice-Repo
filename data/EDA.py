# %%
import pandas as pd

# %%
df = pd.read_csv('C:\\Users\\bhatt\\OneDrive\\Desktop\\Bengaluru Rental Market Analysis\\data\\Bengaluru_rent.csv')

df.head()

# %%
df.shape

# %%
df.info()


# %%
df.columns

# %%
df.isnull().sum()

# %%
df = df.dropna(subset=['bathroom'])
df.info()

# %%
df.duplicated().sum()

# %%
df[df.duplicated()].head(10)

# %% [markdown]
# Dropping duplicate values

# %%
df = df.drop_duplicates()

# %%
df.shape

# %%
df.duplicated().sum()

# %%
df.nunique()

# %%
df.info()

# %%
df

# %% [markdown]
# Changing the data types for prices from str to int as it is an aggregation data metric.

# %%
df['price'] = df['price'].str.replace('₹', '').str.replace(',', '').astype(float)

# %%
df

# %%
df['bedroom'] = df['bedroom'].astype(int)

# %%
df.info()

# %%
df['bathroom'] = df['bathroom'].str.extract('(\d+)')

# %%
df.info()

# %%
df.isnull().sum()

# %% [markdown]
# Now remove the null values if the number accounts for less than 5% of the total dataset.

# %%
df.dropna(subset=['bathroom'], inplace=True)

# %%
df['bathroom']= df['bathroom'].astype(int)

df.info()

# %% [markdown]
# No we calculate the numerical representation for each int type to understand the distribution.

# %%
df.describe()

# %% [markdown]
# The distribution shows: 
# # minimum price to be 1 rs
# # max rooms as 15
# # area at 10800 sq ft
# # bathrooms at 19
# 
# We have to analyze each anomaly that seems like and outlier.
# 
# # i.e Rent could never be 1 rs which could be an outlier requiring further analysis.
# 
# We have to look for values which have the price at 1 and remove if they seem suspicious or out of place, similarly for other values we have to look for a reasonable explanation.
# 
# # i.e A 13 bedroom Villa could have 19 bathroom with 10800 sq ft area but the bathrom count of 19 is also visible for a 2bhk apartment then it's an outlier.

# %%
df.sort_values(by='price').head(200)

# %%
print((df['price'] <= 10).sum())
print(((df['price'] > 10) & (df['price'] < 1000)).sum())

# %%
df[df['price'] <= 10]['price'].value_counts().sort_index()

# %% [markdown]
# Here the data distribution requires more investigation as it is a possibility that the values 1 to 10 might represent a different number.

# %%
df[(df['price'] <= 10) & (df['bedroom'] <= 3)][['price','bedroom','area','locality']].sort_values('price')

# %% [markdown]
# During the analysis for these 197 outliers it was observed that most of these values had been representing different meaning for prices lower than 10.
# 
# Even if these prices were somehow reported less by a calculation error (i.e 10000x or 100000x part of the actual rent), these properties do not hold information that could be relied upon due to the imbalanced rates for areas like Varthur or Vimanapura as these areas represnt a complete different range for renting properties.
# 
# It is safe to delete these values as an error.

# %%
df = df[df['price'] > 10]

# %%
df[df['price'] > 10]['price'].min()

# %% [markdown]
# As we have removed all the values for the outlier we can finally see a dataset which is representing accurate numbers.
# 
# We need to add the rent per sq feet coluimn for all the properties that will provide a deeper insight into locality wise prperty values that can help a person identify the best property for them to choose.   

# %%
df['rent_per_sq_ft'] = df['price'] / df['area']

df.head()

# %%
df.rent_per_sq_ft.describe()

# %%
df.nlargest(10, 'rent_per_sq_ft')[['price', 'area', 'rent_per_sq_ft', 'locality']]

# %%
df.nsmallest(10, 'rent_per_sq_ft')[['price', 'area', 'rent_per_sq_ft', 'locality']]

# %% [markdown]
# Now that the data makes sense, we check the locality wise average rent and total listings to support and check the results are not random.

# %%
listings_summary = locality_summary = (
    df.groupby('locality')
      .agg(
          listings=('price', 'count'),
          avg_rent=('price', 'mean'),
          avg_area=('area', 'mean'),
          avg_rent_per_sqft=('rent_per_sq_ft', 'mean')
      )
      .round(2)
)

# %%
locality_summary.sort_values('listings', ascending=False).head(10)

# %%
df.to_csv('C:\\Users\\bhatt\\OneDrive\\Desktop\\Bengaluru Rental Market Analysis\\data\\Bengaluru_rent_cleaned.csv', index=False)


