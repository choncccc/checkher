// Generated from prototype/font ng layout.pdf (Meal Guide section).
// ignore_for_file: lines_longer_than_80_chars

enum FoodCategory {
  fruits('Fruits'),
  vegetables('Vegetables'),
  dairy('Dairy'),
  protein('Protein'),
  oilsAndFats('Oils & Fats');

  const FoodCategory(this.label);
  final String label;
}

/// A food in the PMOS friendly foods guide.
class Food {
  const Food({
    required this.name,
    required this.category,
    required this.serving,
    required this.nutrition,
    required this.nutrients,
    required this.benefit,
    this.warning,
  });

  final String name;
  final FoodCategory category;
  final String serving;

  /// Label and amount per 100 g; a label may be empty for a plain note.
  final List<(String, String)> nutrition;
  final String nutrients;
  final String benefit;

  /// Shown without needing to open the entry.
  final String? warning;
}

const foods = <Food>[
  Food(
    name: 'Avocado',
    category: FoodCategory.fruits,
    serving: '½ medium (~100g)',
    nutrition: [
      ('Energy', '160 kcal'),
      ('Carbs', '8.5g'),
      ('Fiber', '6.7g'),
      ('Protein', '2.0g'),
      ('Fat', '14.7g'),
    ],
    nutrients: 'Vit C (10mg), Potassium (485mg), Vit E, Folate.',
    benefit:
        'Low net carbs (1.8g). Rich in MUFA fats which delay gastric emptying and flatten postprandial glucose spikes.',
  ),
  Food(
    name: 'Guava',
    category: FoodCategory.fruits,
    serving: '1 medium fruit (~100g)',
    nutrition: [
      ('Energy', '68 kcal'),
      ('Carbs', '14.3g'),
      ('Fiber', '5.4g'),
      ('Sugar', '8.9g'),
      ('Protein', '2.5g'),
    ],
    nutrients: 'Vit C (228.3mg), Potassium (417mg), Vit A.',
    benefit:
        'Exceptional Vit C lowers systemic oxidative stress. High insoluble fiber supports gut microbiome health.',
  ),
  Food(
    name: 'Strawberries',
    category: FoodCategory.fruits,
    serving: '1 cup halves (~152g)',
    nutrition: [
      ('Energy', '32 kcal'),
      ('Carbs', '7.7g'),
      ('Fiber', '2.0g'),
      ('Sugar', '4.9g'),
      ('Protein', '0.7g'),
    ],
    nutrients: 'Vit C (58.8mg), Potassium (153mg), Folate.',
    benefit:
        'Low glycemic load. Anthocyanin antioxidants enhance peripheral insulin sensitivity in tissue.',
  ),
  Food(
    name: 'Raspberries',
    category: FoodCategory.fruits,
    serving: '1 cup (~123g)',
    nutrition: [
      ('Energy', '52 kcal'),
      ('Carbs', '11.9g'),
      ('Fiber', '6.5g'),
      ('Sugar', '4.4g'),
      ('Protein', '1.2g'),
    ],
    nutrients: 'Vit C (26.2mg), Potassium (151mg), Magnesium.',
    benefit:
        'Over 50% carb mass is fiber. Ellagitannins reduce inflammatory cytokines in metabolic tissues.',
  ),
  Food(
    name: 'Blueberries',
    category: FoodCategory.fruits,
    serving: '1 cup (~148g)',
    nutrition: [
      ('Energy', '57 kcal'),
      ('Carbs', '14.5g'),
      ('Fiber', '2.4g'),
      ('Sugar', '10.0g'),
      ('Protein', '0.7g'),
    ],
    nutrients: 'Vit C (9.7mg), Vit K, Anthocyanins.',
    benefit:
        'High polyphenol density improves vascular endothelial function and lipid peroxidation markers.',
  ),
  Food(
    name: 'Blackberries',
    category: FoodCategory.fruits,
    serving: '1 cup (~144g)',
    nutrition: [
      ('Energy', '43 kcal'),
      ('Carbs', '9.6g'),
      ('Fiber', '5.3g'),
      ('Sugar', '4.9g'),
      ('Protein', '1.4g'),
    ],
    nutrients: 'Vit C (21mg), Vit K (19.8µg), Potassium.',
    benefit:
        'Excellent fiber-to-sugar ratio. Promotes short-chain fatty acid (SCFA) production in gut microbiome.',
  ),
  Food(
    name: 'Green Kiwi',
    category: FoodCategory.fruits,
    serving: '1 medium fruit (~69g)',
    nutrition: [
      ('Energy', '61 kcal'),
      ('Carbs', '14.7g'),
      ('Fiber', '3.0g'),
      ('Sugar', '9.0g'),
      ('Protein', '1.1g'),
    ],
    nutrients: 'Vit C (92.7mg), Potassium (312mg), Vit E.',
    benefit:
        'Actinidin enzyme assists in gastrointestinal protein absorption. Great low-GI snack choice.',
  ),
  Food(
    name: 'Papaya',
    category: FoodCategory.fruits,
    serving: '1 cup cubed (~145g)',
    nutrition: [
      ('Energy', '43 kcal'),
      ('Carbs', '10.8g'),
      ('Fiber', '1.7g'),
      ('Sugar', '7.8g'),
      ('Protein', '0.5g'),
    ],
    nutrients: 'Vit C (60.9mg), Potassium (182mg), Beta-Carotene.',
    benefit:
        'Papain enzyme aids protein breakdown. Low calorie density allows flexible meal plan volume.',
  ),
  Food(
    name: 'Apple (with skin)',
    category: FoodCategory.fruits,
    serving: '1 medium fruit (~182g)',
    nutrition: [
      ('Energy', '52 kcal'),
      ('Carbs', '13.8g'),
      ('Fiber', '2.4g'),
      ('Sugar', '10.4g'),
      ('Protein', '0.3g'),
    ],
    nutrients: 'Vit C (4.6mg), Potassium (107mg), Quercetin.',
    benefit:
        'Pectin soluble fiber delays digestion. Quercetin acts as a natural antioxidant reducing systemic inflammation.',
  ),
  Food(
    name: 'Pear (with skin)',
    category: FoodCategory.fruits,
    serving: '1 medium fruit (~178g)',
    nutrition: [
      ('Energy', '57 kcal'),
      ('Carbs', '15.2g'),
      ('Fiber', '3.1g'),
      ('Sugar', '9.8g'),
      ('Protein', '0.4g'),
    ],
    nutrients: 'Vit C (4.3mg), Potassium (116mg), Copper.',
    benefit:
        'Skin contains significant insoluble fiber; helps regulate bowel transit and blunts glycemic impact.',
  ),
  Food(
    name: 'Orange',
    category: FoodCategory.fruits,
    serving: '1 medium (~131g)',
    nutrition: [
      ('Energy', '47 kcal'),
      ('Carbs', '11.8g'),
      ('Fiber', '2.4g'),
      ('Sugar', '9.3g'),
      ('Protein', '0.9g'),
    ],
    nutrients: 'Vit C (53.2mg), Potassium (181mg), Folate.',
    benefit:
        'Whole fruit retains fiber matrix; recommend over fruit juice to avoid rapid fructose absorption.',
  ),
  Food(
    name: 'Cantaloupe',
    category: FoodCategory.fruits,
    serving: '1 cup cubed (~160g)',
    nutrition: [
      ('Energy', '34 kcal'),
      ('Carbs', '8.2g'),
      ('Fiber', '0.9g'),
      ('Sugar', '7.9g'),
      ('Protein', '0.8g'),
    ],
    nutrients: 'Vit C (36.7mg), Vit A (169µg RAE).',
    benefit:
        'High water content (90%); provides electrolyte balance and antioxidant support with minimal caloric load.',
  ),
  Food(
    name: 'Plum',
    category: FoodCategory.fruits,
    serving: '1 medium (~66g)',
    nutrition: [
      ('Energy', '46 kcal'),
      ('Carbs', '11.4g'),
      ('Fiber', '1.4g'),
      ('Sugar', '9.9g'),
      ('Protein', '0.7g'),
    ],
    nutrients: 'Vit C (9.5mg), Vit K (6.4µg), Potassium.',
    benefit:
        'Rich in anthocyanins and neochlorogenic acid which attenuate metabolic syndrome markers.',
  ),
  Food(
    name: 'Pomegranate Arils',
    category: FoodCategory.fruits,
    serving: '½ cup arils (~87g)',
    nutrition: [
      ('Energy', '83 kcal'),
      ('Carbs', '18.7g'),
      ('Fiber', '4.0g'),
      ('Sugar', '13.7g'),
      ('Protein', '1.7g'),
    ],
    nutrients: 'Vit C (10.2mg), Potassium (236mg), Punicalagins.',
    benefit:
        'Bioactive polyphenols significantly reduce hs-CRP and serum inflammatory markers elevated in PMOS.',
  ),
  Food(
    name: 'Dragon Fruit (Pitaya)',
    category: FoodCategory.fruits,
    serving: '1 cup cubed (~140g)',
    nutrition: [
      ('Energy', '57 kcal'),
      ('Carbs', '13.0g'),
      ('Fiber', '3.1g'),
      ('Sugar', '7.7g'),
      ('Protein', '1.2g'),
    ],
    nutrients: 'Vit C (4.0mg), Iron (0.7mg), Magnesium.',
    benefit:
        'Seeds contain prebiotic fiber and essential fatty acids, supporting gut health and glycemic control.',
  ),
  Food(
    name: 'Pomelo',
    category: FoodCategory.fruits,
    serving: '1 cup sections (~190g)',
    nutrition: [
      ('Energy', '38 kcal'),
      ('Carbs', '9.6g'),
      ('Fiber', '1.0g'),
      ('Sugar', '7.0g'),
      ('Protein', '0.8g'),
    ],
    nutrients: 'Vit C (61.0mg), Potassium (216mg).',
    benefit: 'High Vit C density.',
    warning:
        'May interact with some medicines because it contains furanocoumarins (CYP3A4 interaction). Ask your doctor or pharmacist if you take regular medication.',
  ),
  Food(
    name: 'Star Fruit (Carambola)',
    category: FoodCategory.fruits,
    serving: '1 medium (~91g)',
    nutrition: [
      ('Energy', '31 kcal'),
      ('Carbs', '6.7g'),
      ('Fiber', '2.8g'),
      ('Sugar', '4.0g'),
      ('Protein', '1.0g'),
    ],
    nutrients: 'Vit C (34.4mg), Potassium (133mg), Copper.',
    benefit: 'Extremely low GI.',
    warning:
        'Avoid if you have kidney disease or reduced kidney function: star fruit contains caramboxin, which can be harmful.',
  ),
  Food(
    name: 'Lanzones (Langsat)',
    category: FoodCategory.fruits,
    serving: '5-6 fruits (~100g)',
    nutrition: [
      ('Energy', '57 kcal'),
      ('Carbs', '14.0g'),
      ('Fiber', '2.0g'),
      ('Sugar', '8.0g'),
      ('Protein', '0.8g'),
    ],
    nutrients: 'Vit C (10mg), Potassium (275mg), B-Vitamins.',
    benefit:
        'Philippine local staple; provides moderate GI carbohydrates combined with natural polyphenols.',
  ),
  Food(
    name: 'Peach',
    category: FoodCategory.fruits,
    serving: '1 medium (~150g)',
    nutrition: [
      ('Energy', '39 kcal'),
      ('Carbs', '9.5g'),
      ('Fiber', '1.5g'),
      ('Sugar', '8.4g'),
      ('Protein', '0.9g'),
    ],
    nutrients: 'Vit C (6.6mg), Potassium (190mg), Niacin.',
    benefit:
        'Low GI fruit; skin contains carotenoids and chlorogenic acid supporting metabolic health.',
  ),
  Food(
    name: 'Mango (Ripe / Sweet - Mangga)',
    category: FoodCategory.fruits,
    serving: '1 cup sliced (~165g)',
    nutrition: [
      ('Energy', '60 kcal'),
      ('Carbs', '15.0g'),
      ('Fiber', '1.6g'),
      ('Sugar', '13.7g'),
      ('Protein', '0.8g'),
      ('Fat', '0.4g'),
    ],
    nutrients: 'Vit C (36.4mg), Vit A (54µg RAE), Mangiferin, Folate.',
    benefit:
        'Contains bioactive xanthone mangiferin, which exhibits anti-diabetic and metabolic-stabilizing properties. Pair with a protein or fat source to flatten glycemic spikes.',
  ),
  Food(
    name: 'Pineapple (Nenas / Pinya)',
    category: FoodCategory.fruits,
    serving: '1 cup chunks (~165g)',
    nutrition: [
      ('Energy', '50 kcal'),
      ('Carbs', '13.1g'),
      ('Fiber', '1.4g'),
      ('Sugar', '9.9g'),
      ('Protein', '0.5g'),
      ('Fat', '0.1g'),
    ],
    nutrients: 'Vit C (47.8mg), Manganese (0.9mg), Bromelain.',
    benefit:
        'Bromelain proteolytic enzyme complex acts as a powerful anti-inflammatory agent, helping reduce systemic tissue edema and pelvic inflammation.',
  ),
  Food(
    name: 'Spinach',
    category: FoodCategory.vegetables,
    serving: '2 cups raw (~60g)',
    nutrition: [
      ('Energy', '23 kcal'),
      ('Carbs', '3.6g'),
      ('Fiber', '2.2g'),
      ('Protein', '2.9g'),
    ],
    nutrients: 'Folate (194µg), Vit A, Vit K, Iron, Magnesium (79mg).',
    benefit:
        'High magnesium enhances cellular insulin sensitivity and assists in LH/FSH balance.',
  ),
  Food(
    name: 'Kale',
    category: FoodCategory.vegetables,
    serving: '1 cup chopped (~67g)',
    nutrition: [
      ('Energy', '35 kcal'),
      ('Carbs', '4.4g'),
      ('Fiber', '4.1g'),
      ('Protein', '2.9g'),
    ],
    nutrients: 'Vit C (93mg), Vit K (389µg), Calcium.',
    benefit:
        'Dense glucosinolate content supports phase II liver detoxification of excess circulating estrogens.',
  ),
  Food(
    name: 'Cauliflower',
    category: FoodCategory.vegetables,
    serving: '1 cup chopped (~107g)',
    nutrition: [
      ('Energy', '25 kcal'),
      ('Carbs', '5.0g'),
      ('Fiber', '2.0g'),
      ('Protein', '1.9g'),
    ],
    nutrients: 'Vit C (48.2mg), Choline, Vit K.',
    benefit:
        'Versatile low-carb rice/mash substitute. Choline supports hepatic fat metabolism in PMOS-related NAFLD.',
  ),
  Food(
    name: 'Bitter Gourd (Ampalaya)',
    category: FoodCategory.vegetables,
    serving: '1 cup chopped (~93g)',
    nutrition: [
      ('Energy', '17 kcal'),
      ('Carbs', '3.7g'),
      ('Fiber', '2.8g'),
      ('Protein', '1.0g'),
    ],
    nutrients: 'Vit C (84mg), Charantin, Polypeptide-p, Folate.',
    benefit:
        'Bioactive charantin exerts insulin-mimetic action, directly lowering postprandial blood glucose.',
  ),
  Food(
    name: 'Moringa Leaves (Malunggay)',
    category: FoodCategory.vegetables,
    serving: '1 cup fresh (~21g)',
    nutrition: [
      ('Energy', '64 kcal'),
      ('Carbs', '8.3g'),
      ('Fiber', '2.0g'),
      ('Protein', '9.4g'),
    ],
    nutrients: 'Vit C (51.7mg), Calcium (185mg), Iron.',
    benefit:
        'Outstanding plant protein and iron density for greens; reduces chronic low-grade inflammation.',
  ),
  Food(
    name: 'Green Cabbage',
    category: FoodCategory.vegetables,
    serving: '1 cup chopped (~89g)',
    nutrition: [
      ('Energy', '25 kcal'),
      ('Carbs', '5.8g'),
      ('Fiber', '2.5g'),
      ('Protein', '1.3g'),
    ],
    nutrients: 'Vit C (36.6mg), Vit K (76µg), Glutamine.',
    benefit:
        'Glutamine supports intestinal mucosal barrier integrity, reducing endotoxin-induced insulin resistance.',
  ),
  Food(
    name: 'Brussels Sprouts',
    category: FoodCategory.vegetables,
    serving: '1 cup (~88g)',
    nutrition: [
      ('Energy', '43 kcal'),
      ('Carbs', '9.0g'),
      ('Fiber', '3.8g'),
      ('Protein', '3.4g'),
    ],
    nutrients: 'Vit C (85mg), Vit K (177µg), Folate.',
    benefit:
        'High fiber density delays carbohydrate digestion. Sulforaphane supports hepatic hormone clearance.',
  ),
  Food(
    name: 'Asparagus',
    category: FoodCategory.vegetables,
    serving: '4 spears (~60g)',
    nutrition: [
      ('Energy', '20 kcal'),
      ('Carbs', '3.9g'),
      ('Fiber', '2.1g'),
      ('Protein', '2.2g'),
    ],
    nutrients: 'Folate (52µg), Vit K (41.6µg), Chromium.',
    benefit:
        'Chromium is an essential cofactor for insulin receptor activity, enhancing glucose uptake efficiency.',
  ),
  Food(
    name: 'Zucchini',
    category: FoodCategory.vegetables,
    serving: '1 cup sliced (~113g)',
    nutrition: [
      ('Energy', '17 kcal'),
      ('Carbs', '3.1g'),
      ('Fiber', '1.0g'),
      ('Protein', '1.2g'),
    ],
    nutrients: 'Vit C (17.9mg), Potassium (261mg), Vit B6.',
    benefit:
        'Very low calorie and carb density; ideal volume ingredient for balancing meal caloric density.',
  ),
  Food(
    name: 'Eggplant (Talong)',
    category: FoodCategory.vegetables,
    serving: '1 cup cooked (~99g)',
    nutrition: [
      ('Energy', '25 kcal'),
      ('Carbs', '5.9g'),
      ('Fiber', '3.0g'),
      ('Protein', '1.0g'),
    ],
    nutrients: 'Nasunin (Antioxidant), Potassium, Vit B6.',
    benefit:
        'Skin nasunin protects vascular cell membranes from lipid peroxidation in metabolic syndrome.',
  ),
  Food(
    name: 'Okra',
    category: FoodCategory.vegetables,
    serving: '8 pods (~80g)',
    nutrition: [
      ('Energy', '33 kcal'),
      ('Carbs', '7.5g'),
      ('Fiber', '3.2g'),
      ('Protein', '1.9g'),
    ],
    nutrients: 'Vit C (23mg), Folate (60µg), Magnesium.',
    benefit:
        'Soluble mucilage fiber binds luminal cholesterol and flattens postprandial glucose absorption curves.',
  ),
  Food(
    name: 'Cucumber (with peel)',
    category: FoodCategory.vegetables,
    serving: '1 cup sliced (~104g)',
    nutrition: [
      ('Energy', '15 kcal'),
      ('Carbs', '3.6g'),
      ('Fiber', '0.5g'),
      ('Protein', '0.7g'),
    ],
    nutrients: 'Vit K (16.4µg), Potassium (147mg), Silica.',
    benefit:
        'High hydration index; peel provides silica and flavonoids supporting connective tissue health.',
  ),
  Food(
    name: 'Bell Pepper (Red)',
    category: FoodCategory.vegetables,
    serving: '1 cup chopped (~149g)',
    nutrition: [
      ('Energy', '26 kcal'),
      ('Carbs', '6.0g'),
      ('Fiber', '2.1g'),
      ('Protein', '1.0g'),
    ],
    nutrients: 'Vit C (127.7mg), Vit A, Capsaicin.',
    benefit:
        'Delivers over 140% daily Vit C per serving, combating elevated ROS levels in ovarian tissue.',
  ),
  Food(
    name: 'Broccoli Rabe (Rapini - Cooked)',
    category: FoodCategory.vegetables,
    serving: '1 cup chopped (~85g)',
    nutrition: [
      ('Energy', '33 kcal'),
      ('Carbs', '3.1g'),
      ('Fiber', '2.7g'),
      ('Protein', '3.8g'),
      ('Fat', '0.5g'),
    ],
    nutrients:
        'Vit A, Vit C (20.2mg), Vit K (224µg), Folate (83µg), Glucosinolates.',
    benefit:
        'Bitter cruciferous veggie dense in Indole-3-Carbinol (I3C), promoting 2-hydroxyestrone metabolism over inflammatory 16-alpha-hydroxyestrone.',
  ),
  Food(
    name: 'Swiss Chard (Cooked)',
    category: FoodCategory.vegetables,
    serving: '1 cup (~175g)',
    nutrition: [
      ('Energy', '20 kcal'),
      ('Carbs', '4.1g'),
      ('Fiber', '2.1g'),
      ('Protein', '1.9g'),
      ('Fat', '0.1g'),
    ],
    nutrients: 'Magnesium (81mg), Potassium (549mg), Syringic Acid, Betalains.',
    benefit:
        'Syringic acid inhibits alpha-glucosidase activity; high magnesium concentration activates insulin receptor tyrosine kinase.',
  ),
  Food(
    name: 'Bok Choy (Petchay - Cooked)',
    category: FoodCategory.vegetables,
    serving: '1 cup shredded (~170g)',
    nutrition: [
      ('Energy', '12 kcal'),
      ('Carbs', '1.8g'),
      ('Fiber', '1.0g'),
      ('Protein', '1.6g'),
      ('Fat', '0.2g'),
    ],
    nutrients: 'Calcium (158mg), Vit C (44mg), Vit A, Selenium.',
    benefit:
        'Highly bioavailable bio-calcium with low oxalate content. Ideal non-dairy source for maintaining bone density during weight loss.',
  ),
  Food(
    name: 'Green Beans (String Beans - Sitaw)',
    category: FoodCategory.vegetables,
    serving: '1 cup (~125g)',
    nutrition: [
      ('Energy', '31 kcal'),
      ('Carbs', '7.0g'),
      ('Fiber', '3.4g'),
      ('Protein', '1.8g'),
      ('Fat', '0.1g'),
    ],
    nutrients: 'Silicon, Vit C (12.2mg), Vit K, Lutein.',
    benefit:
        'Moderate fiber, low glycation footprint. Provides dietary silicon for collagen synthesis and follicular connective tissue.',
  ),
  Food(
    name: 'Radish (White/Red - Labanos)',
    category: FoodCategory.vegetables,
    serving: '1 cup sliced (~116g)',
    nutrition: [
      ('Energy', '16 kcal'),
      ('Carbs', '3.4g'),
      ('Fiber', '1.6g'),
      ('Protein', '0.7g'),
      ('Fat', '0.1g'),
    ],
    nutrients: 'Vit C (14.8mg), Potassium, Isothiocyanates, Myrosinase.',
    benefit:
        'Contains sulfur compounds that stimulate bile production and enhance hepatic lipid oxidation, assisting in NAFLD mitigation.',
  ),
  Food(
    name: 'Greek Yogurt (Plain, 0%)',
    category: FoodCategory.dairy,
    serving: '1 cup (~170g)',
    nutrition: [
      ('Energy', '59 kcal'),
      ('Carbs', '3.6g'),
      ('Protein', '10.2g'),
      ('Fat', '0.4g'),
    ],
    nutrients: 'Calcium (110mg), Vit B12, Probiotics.',
    benefit:
        'Concentrated whey removal provides 2x protein of regular yogurt, blunting appetite via peptide YY stimulation.',
  ),
  Food(
    name: 'Greek Yogurt (Plain, 2%)',
    category: FoodCategory.dairy,
    serving: '1 cup (~170g)',
    nutrition: [
      ('Energy', '73 kcal'),
      ('Carbs', '3.9g'),
      ('Protein', '9.9g'),
      ('Fat', '2.0g'),
    ],
    nutrients: 'Calcium (115mg), Iodine, Probiotics.',
    benefit:
        'Moderate fat content aids fat-soluble vitamin uptake (Vit A/D) and increases long-term satiety.',
  ),
  Food(
    name: 'Unsweetened Almond Milk',
    category: FoodCategory.dairy,
    serving: '1 cup (~240ml)',
    nutrition: [
      ('Energy', '15 kcal'),
      ('Carbs', '0.3g'),
      ('Protein', '0.6g'),
      ('Fat', '1.2g'),
    ],
    nutrients: 'Vit E (3.3mg), Fortified Calcium (120mg).',
    benefit:
        'Zero-sugar dairy alternative; ideal for women experiencing dairy-triggered inflammatory flares or acne.',
  ),
  Food(
    name: 'Unsweetened Soy Milk',
    category: FoodCategory.dairy,
    serving: '1 cup (~240ml)',
    nutrition: [
      ('Energy', '33 kcal'),
      ('Carbs', '1.8g'),
      ('Protein', '2.8g'),
      ('Fat', '1.6g'),
    ],
    nutrients: 'Isoflavones, Fortified Calcium, Vit B12.',
    benefit:
        'Complete plant protein source; naturally occurring isoflavones exert weak, protective estrogen-modulating effects.',
  ),
  Food(
    name: 'Cottage Cheese (Low Fat)',
    category: FoodCategory.dairy,
    serving: '½ cup (~113g)',
    nutrition: [
      ('Energy', '81 kcal'),
      ('Carbs', '4.7g'),
      ('Protein', '11.1g'),
      ('Fat', '2.3g'),
    ],
    nutrients: 'Calcium (86mg), Selenium, Phosphorus.',
    benefit:
        'High slow-digesting casein protein content provides steady amino acid release, stabilizing nocturnal blood sugar.',
  ),
  Food(
    name: 'Kefir (Plain, Low Fat)',
    category: FoodCategory.dairy,
    serving: '1 cup (~243g)',
    nutrition: [
      ('Energy', '43 kcal'),
      ('Carbs', '4.8g'),
      ('Protein', '3.8g'),
      ('Fat', '1.0g'),
    ],
    nutrients: 'Probiotics (diverse live strains), Calcium.',
    benefit:
        'Fermentation significantly enhances gut microbiome diversity, linked to reduced systemic LPS endotoxemia.',
  ),
  Food(
    name: 'Feta Cheese',
    category: FoodCategory.dairy,
    serving: '1 oz (~28g)',
    nutrition: [
      ('Energy', '264 kcal'),
      ('Carbs', '4.1g'),
      ('Protein', '14.2g'),
      ('Fat', '21.3g'),
    ],
    nutrients: 'Calcium (493mg), Phosphorus, Vit B12.',
    benefit:
        'Aged sheep/goat cheese low in lactose; best utilized as an accent ingredient for flavor and lipid absorption.',
  ),
  Food(
    name: 'Paneer (Cottage Cheese)',
    category: FoodCategory.dairy,
    serving: '100g',
    nutrition: [
      ('Energy', '265 kcal'),
      ('Carbs', '3.2g'),
      ('Protein', '18.3g'),
      ('Fat', '20.8g'),
    ],
    nutrients: 'Calcium (480mg), Phosphorus.',
    benefit:
        'High-protein vegetarian staple; provides dense amino acid substrate without elevating blood glucose.',
  ),
  Food(
    name: 'Unsweetened Coconut Milk (Carton)',
    category: FoodCategory.dairy,
    serving: '1 cup (~240ml)',
    nutrition: [
      ('Energy', '19 kcal'),
      ('Carbs', '0.4g'),
      ('Protein', '0.2g'),
      ('Fat', '2.0g'),
    ],
    nutrients: 'Lauric Acid (MCT), Fortified Calcium (120mg), Vit B12.',
    benefit:
        'Low-carb alternative rich in medium-chain triglycerides (MCTs) that bypass standard lymphatic fat transport for rapid hepatic energy conversion.',
  ),
  Food(
    name: 'Unsweetened Hemp Milk',
    category: FoodCategory.dairy,
    serving: '1 cup (~240ml)',
    nutrition: [
      ('Energy', '25 kcal'),
      ('Carbs', '0.4g'),
      ('Protein', '1.3g'),
      ('Fat', '2.1g'),
    ],
    nutrients: 'Gamma-Linolenic Acid (GLA), Omega-3/6 ratio (1:3), Iron.',
    benefit:
        'Contains GLA, an anti-inflammatory omega-6 derivative that modulates prolactin receptor sensitivity and alleviates premenstrual mastalgia.',
  ),
  Food(
    name: 'Goat Cheese (Soft Chèvre)',
    category: FoodCategory.dairy,
    serving: '1 oz (~28g)',
    nutrition: [
      ('Energy', '268 kcal'),
      ('Carbs', '0.9g'),
      ('Protein', '18.5g'),
      ('Fat', '21.1g'),
    ],
    nutrients: 'A2 Beta-Casein, Calcium (140mg), Phosphorus, Vit A.',
    benefit:
        'Predominantly A2 beta-casein structure; avoids BCM-7 inflammatory peptide release linked to A1 cow dairy, reducing gut irritation.',
  ),
  Food(
    name: 'Chicken Breast (Skinless)',
    category: FoodCategory.protein,
    serving: '1 cooked breast (~120g)',
    nutrition: [
      ('Energy', '165 kcal'),
      ('Carbs', '0.0g'),
      ('Protein', '31.0g'),
      ('Fat', '3.6g'),
    ],
    nutrients: 'Niacin (B3), Vit B6, Selenium, Phosphorus.',
    benefit:
        'Ultra-lean protein source; stimulates GLP-1 release and supports skeletal muscle glucose disposal.',
  ),
  Food(
    name: 'Chicken Thigh (Skinless)',
    category: FoodCategory.protein,
    serving: '1 cooked thigh (~100g)',
    nutrition: [
      ('Energy', '209 kcal'),
      ('Carbs', '0.0g'),
      ('Protein', '26.0g'),
      ('Fat', '10.9g'),
    ],
    nutrients: 'Zinc, Iron, Vit B12, Niacin.',
    benefit:
        'Higher zinc and iron content than breast meat; zinc aids in androgen receptor down-regulation.',
  ),
  Food(
    name: 'Salmon',
    category: FoodCategory.protein,
    serving: '1 filet (~120g)',
    nutrition: [
      ('Energy', '206 kcal'),
      ('Protein', '22.1g'),
      ('Fat', '12.3g'),
      ('Omega-3', '1.8g'),
    ],
    nutrients: 'Vit D (526 IU), Vit B12, Selenium.',
    benefit:
        'Long-chain EPA/DHA reduces serum testosterone and vascular inflammation while Vit D supports follicular maturation.',
  ),
  Food(
    name: 'Tuna (Yellowfin/Skipjack, Water)',
    category: FoodCategory.protein,
    serving: '1 can (~120g)',
    nutrition: [
      ('Energy', '128 kcal'),
      ('Carbs', '0.0g'),
      ('Protein', '28.0g'),
      ('Fat', '1.0g'),
    ],
    nutrients: 'Selenium, Niacin, Vit B12, Phosphorus.',
    benefit:
        'Pure lean protein; high selenium content supports thyroid peroxidase activity and T4 to T3 conversion.',
  ),
  Food(
    name: 'Eggs (Whole, Hard-Boiled)',
    category: FoodCategory.protein,
    serving: '2 large eggs (~100g)',
    nutrition: [
      ('Energy', '155 kcal'),
      ('Carbs', '1.1g'),
      ('Protein', '12.6g'),
      ('Fat', '10.6g'),
    ],
    nutrients: 'Choline (294mg), Vit D, Vit A, Lutein.',
    benefit:
        'Yolk choline is required for VLDL assembly in liver, helping mitigate non-alcoholic fatty liver disease (NAFLD).',
  ),
  Food(
    name: 'Egg Whites',
    category: FoodCategory.protein,
    serving: '4 large whites (~132g)',
    nutrition: [
      ('Energy', '52 kcal'),
      ('Carbs', '0.7g'),
      ('Protein', '10.9g'),
      ('Fat', '0.2g'),
    ],
    nutrients: 'Riboflavin (B2), Potassium.',
    benefit:
        'Fat-free pure ovalbumin protein; ideal for adding volume and protein without adding dietary lipids.',
  ),
  Food(
    name: 'Lean Beef Sirloin',
    category: FoodCategory.protein,
    serving: '1 steak (~120g)',
    nutrition: [
      ('Energy', '183 kcal'),
      ('Carbs', '0.0g'),
      ('Protein', '29.2g'),
      ('Fat', '6.7g'),
    ],
    nutrients: 'Heme Iron (2.6mg), Zinc (5.8mg), Vit B12.',
    benefit:
        'Highly bioavailable heme iron addresses anemia risk from heavy menstrual bleeding common in anovulatory PMOS.',
  ),
  Food(
    name: 'Pork Tenderloin',
    category: FoodCategory.protein,
    serving: '1 roast portion (~120g)',
    nutrition: [
      ('Energy', '143 kcal'),
      ('Carbs', '0.0g'),
      ('Protein', '26.2g'),
      ('Fat', '3.5g'),
    ],
    nutrients: 'Thiamin (B1 0.9mg), Vit B6, Zinc, Selenium.',
    benefit:
        'Lean red meat alternative; thiamin acts as essential coenzyme in mitochondrial carbohydrate metabolism.',
  ),
  Food(
    name: 'Firm Tofu',
    category: FoodCategory.protein,
    serving: '1 cup cubed (~126g)',
    nutrition: [
      ('Energy', '144 kcal'),
      ('Carbs', '2.8g'),
      ('Protein', '17.3g'),
      ('Fat', '8.7g'),
    ],
    nutrients: 'Calcium (683mg), Iron (2.7mg), Isoflavones.',
    benefit:
        'Phytoestrogens bind ER-beta receptors, exerting favorable lipid-modulating and anti-androgenic effects.',
  ),
  Food(
    name: 'Tempeh',
    category: FoodCategory.protein,
    serving: '1 cup (~166g)',
    nutrition: [
      ('Energy', '193 kcal'),
      ('Carbs', '9.4g'),
      ('Protein', '20.3g'),
      ('Fat', '10.8g'),
    ],
    nutrients: 'Manganese, Copper, Probiotics, Magnesium.',
    benefit:
        'Fermented soy matrix enhances digestive bioavailability and delivers gut-friendly probiotic microorganisms.',
  ),
  Food(
    name: 'Shrimp / Prawns',
    category: FoodCategory.protein,
    serving: '10-12 large (~100g)',
    nutrition: [
      ('Energy', '99 kcal'),
      ('Carbs', '0.2g'),
      ('Protein', '24.0g'),
      ('Fat', '0.3g'),
    ],
    nutrients: 'Selenium, Iodine, Vit B12, Astaxanthin.',
    benefit:
        'Astaxanthin pigment provides potent antioxidant protection against follicular lipid peroxidation.',
  ),
  Food(
    name: 'Turkey Breast (Skinless, Roasted)',
    category: FoodCategory.protein,
    serving: '1 portion (~120g)',
    nutrition: [
      ('Energy', '135 kcal'),
      ('Carbs', '0.0g'),
      ('Protein', '30.0g'),
      ('Fat', '1.0g'),
    ],
    nutrients: 'L-Tryptophan, Selenium (31µg), Vit B6, Niacin.',
    benefit:
        'Exceptional Tryptophan-to-LNAA ratio; supports serotonin and melatonin synthesis, stabilizing mood and circadian cortisol rhythms.',
  ),
  Food(
    name: 'Sardines (Canned in Water / Olive Oil)',
    category: FoodCategory.protein,
    serving: '1 can drained (~92g)',
    nutrition: [
      ('Energy', '208 kcal'),
      ('Carbs', '0.0g'),
      ('Protein', '24.6g'),
      ('Fat', '11.5g'),
      ('Omega-3', '1.4g'),
    ],
    nutrients: 'Vit D (192 IU), Calcium (382mg), Vit B12 (8.9µg), Selenium.',
    benefit:
        'Small, short-lived fish with near-zero heavy metal bioaccumulation. Delivers bone-in calcium and EPA/DHA to reduce hyperandrogenemia.',
  ),
  Food(
    name: 'Tilapia (Fillet, Baked)',
    category: FoodCategory.protein,
    serving: '1 fillet (~116g)',
    nutrition: [
      ('Energy', '128 kcal'),
      ('Carbs', '0.0g'),
      ('Protein', '26.0g'),
      ('Fat', '2.7g'),
    ],
    nutrients: 'Selenium (54µg), Vit B12, Phosphorus, Potassium.',
    benefit:
        'Accessible, highly digestible lean fish protein. High selenium content supports thyroid deiodinase enzymatic conversion.',
  ),
  Food(
    name: 'Extra Virgin Olive Oil',
    category: FoodCategory.oilsAndFats,
    serving: '1 tbsp (~14g)',
    nutrition: [
      ('Energy', '884 kcal'),
      ('Fat', '100g'),
      ('Vit E', '14.3mg'),
      ('', '73% MUFA'),
    ],
    nutrients: 'Oleocanthal, Oleic Acid.',
    benefit:
        'Natural COX-1/COX-2 inhibitor; reduces chronic vascular inflammation and improves endothelial dysfunction.',
  ),
  Food(
    name: 'Avocado Oil',
    category: FoodCategory.oilsAndFats,
    serving: '1 tbsp (~14g)',
    nutrition: [
      ('Energy', '884 kcal'),
      ('Fat', '100g'),
      ('', '70% MUFA High Smoke Point'),
    ],
    nutrients: 'Lutein, Vit E.',
    benefit:
        'Heat-stable cooking oil rich in oleic acid; prevents toxic lipid peroxide formation during high-heat meal preparation.',
  ),
  Food(
    name: 'Flaxseed Oil',
    category: FoodCategory.oilsAndFats,
    serving: '1 tbsp (~14g)',
    nutrition: [
      ('Energy', '884 kcal'),
      ('Fat', '100g'),
      ('', '53% ALA Omega-3'),
    ],
    nutrients: 'Alpha-Linolenic Acid.',
    benefit:
        'Highly heat-sensitive (use cold only); plant omega-3 precursor that suppresses proinflammatory arachidonic acid pathways.',
  ),
  Food(
    name: 'Walnuts',
    category: FoodCategory.oilsAndFats,
    serving: '7 whole nuts (~28g)',
    nutrition: [
      ('Energy', '654 kcal'),
      ('Fiber', '6.7g'),
      ('Protein', '15.2g'),
      ('Fat', '65.2g'),
    ],
    nutrients: 'ALA Omega-3 (9% total fat), Vit E, Polyphenols.',
    benefit:
        'Uniquely high in plant omega-3s; clinical studies demonstrate improved lipid profiles and insulin sensitivity in PMOS.',
  ),
  Food(
    name: 'Almonds',
    category: FoodCategory.oilsAndFats,
    serving: '23 nuts (~28g)',
    nutrition: [
      ('Energy', '579 kcal'),
      ('Fiber', '12.5g'),
      ('Protein', '21.2g'),
      ('Fat', '49.9g'),
    ],
    nutrients: 'Vit E (25.6mg), Magnesium (270mg).',
    benefit:
        'Rich in oleic acid MUFA; shown to reduce free androgen index (FAI) and improve serum lipid ratios.',
  ),
  Food(
    name: 'Pumpkin Seeds (Pepitas)',
    category: FoodCategory.oilsAndFats,
    serving: '1 oz (~28g)',
    nutrition: [
      ('Energy', '559 kcal'),
      ('Fiber', '6.0g'),
      ('Protein', '30.2g'),
      ('Fat', '49.0g'),
    ],
    nutrients: 'Zinc (7.8mg), Magnesium (592mg), Iron.',
    benefit:
        'High zinc content inhibits 5-alpha reductase enzyme, slowing peripheral conversion of testosterone to potent DHT.',
  ),
  Food(
    name: 'Sunflower Seeds',
    category: FoodCategory.oilsAndFats,
    serving: '1 oz (~28g)',
    nutrition: [
      ('Energy', '584 kcal'),
      ('Fiber', '8.6g'),
      ('Protein', '20.8g'),
      ('Fat', '51.5g'),
    ],
    nutrients: 'Vit E (35.2mg), Selenium (53µg).',
    benefit:
        'Delivers over 100% RDI Vit E per portion; neutralizes lipid peroxides in granulosa cells.',
  ),
  Food(
    name: 'Sesame Seeds (Til)',
    category: FoodCategory.oilsAndFats,
    serving: '1 tbsp (~9g)',
    nutrition: [
      ('Energy', '573 kcal'),
      ('Fiber', '11.8g'),
      ('Protein', '17.7g'),
      ('Fat', '49.7g'),
    ],
    nutrients: 'Sesamin (Lignan), Calcium (975mg).',
    benefit:
        'Sesamin lignans inhibit delta-5-desaturase enzyme, lowering proinflammatory lipid mediator cascade synthesis.',
  ),
  Food(
    name: 'Macadamia Nuts',
    category: FoodCategory.oilsAndFats,
    serving: '10-12 nuts (~28g)',
    nutrition: [
      ('Energy', '718 kcal'),
      ('Fiber', '8.6g'),
      ('Protein', '7.9g'),
      ('Fat', '75.8g'),
    ],
    nutrients: 'Thiamin (B1), Manganese, Palmitoleic Acid.',
    benefit:
        '80% MUFA fat profile; low net carb content helps maintain steady ketone/glucose homeostasis.',
  ),
  Food(
    name: 'Brazil Nuts',
    category: FoodCategory.oilsAndFats,
    serving: '1-2 nuts (~5g)',
    nutrition: [
      ('Energy', '656 kcal'),
      ('Fiber', '7.5g'),
      ('Protein', '14.3g'),
      ('Fat', '66.4g'),
    ],
    nutrients: 'Selenium (1917µg/100g).',
    benefit:
        'Just ONE nut provides 100% Daily Value of selenium; optimizes thyroid hormone deiodinase activity.',
  ),
  Food(
    name: 'Virgin Coconut Oil',
    category: FoodCategory.oilsAndFats,
    serving: '1 tbsp (~14g)',
    nutrition: [
      ('Energy', '862 kcal'),
      ('Fat', '100g'),
      ('', '86% Saturated (MCTs)'),
    ],
    nutrients: 'Lauric Acid, Caprylic Acid.',
    benefit:
        'Rapidly oxidized in liver for energy; use moderate portions to manage saturated fat intake.',
  ),
  Food(
    name: 'Chia Seeds',
    category: FoodCategory.oilsAndFats,
    serving: '2 tbsp (~28g)',
    nutrition: [
      ('Energy', '486 kcal'),
      ('Carbs', '42.1g'),
      ('Fiber', '34.4g'),
      ('Protein', '16.5g'),
      ('Fat', '30.7g'),
    ],
    nutrients: 'ALA Omega-3 (5g/serving), Calcium (179mg), Magnesium (95mg).',
    benefit:
        'Net carbs = 2g per serving. Soluble mucilage forms a gel matrix that slows gastric emptying and improves postprandial glucose stability.',
  ),
  Food(
    name: 'Hemp Seeds (Hemp Hearts)',
    category: FoodCategory.oilsAndFats,
    serving: '3 tbsp (~30g)',
    nutrition: [
      ('Energy', '553 kcal'),
      ('Carbs', '8.7g'),
      ('Fiber', '4.0g'),
      ('Protein', '31.6g'),
      ('Fat', '48.8g'),
    ],
    nutrients: 'GLA, Zinc (9.9mg), Magnesium (700mg), Iron (8mg).',
    benefit:
        'Ideal 3:1 Omega-6 to Omega-3 ratio + GLA. Exceptionally high zinc/magnesium density supports progesterone synthesis.',
  ),
  Food(
    name: 'Pecans',
    category: FoodCategory.oilsAndFats,
    serving: '19 halves (~28g)',
    nutrition: [
      ('Energy', '691 kcal'),
      ('Carbs', '13.9g'),
      ('Fiber', '9.6g'),
      ('Protein', '9.2g'),
      ('Fat', '72.0g'),
    ],
    nutrients: 'Gamma-Tocopherol (Vit E), Manganese (4.5mg), Zinc.',
    benefit:
        'Highest total polyphenol content among tree nuts. Gamma-tocopherol form of Vit E protects vascular endothelial lining from ROS damage.',
  ),
];
