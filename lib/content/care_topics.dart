import 'package:flutter/material.dart';

/// A block of text in a care article: either a paragraph or a bullet point.
class CareBlock {
  const CareBlock.paragraph(this.text) : bullet = false, bold = false;
  const CareBlock.heading(this.text) : bullet = false, bold = true;
  const CareBlock.bullet(this.text) : bullet = true, bold = false;
  final String text;
  final bool bullet;
  final bool bold;
}

class CareTopic {
  const CareTopic({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.blocks,
  });
  final String title;
  final String subtitle;
  final IconData icon; // TODO: swap for the illustrated badge icons
  final List<CareBlock> blocks;
}

const careTopics = <CareTopic>[
  CareTopic(
    title: 'Healthy Eating',
    subtitle: 'BALANCE DIET TO SUPPORT NUTRITIONAL NEEDS',
    icon: Icons.restaurant,
    blocks: [
      CareBlock.bullet(
        'Eat a combination of different foods, including staple foods (such as cereals like wheat, barley, rye, maize or rice, or roots such as potato, yam, taro or cassava), legumes (such as lentils and beans), plenty of fresh vegetables, and fruit of various kinds.',
      ),
      CareBlock.bullet(
        'Consume at least 400 grams (i.e., five portions) of fruit and vegetables per day, excluding potatoes, sweet potatoes, cassava and other starchy roots.',
      ),
      CareBlock.bullet(
        'Keep total fat intake to less than 30% of total energy intake to help prevent unhealthy weight gain, ensuring that unsaturated fats (found in fish, avocado, nuts, and sunflower, soybean, canola and olive oils) are consumed rather than saturated fats (found in fatty meat, butter, palm and coconut oil, cream, cheese, ghee and lard) and trans-fats of all kinds.',
      ),
      CareBlock.bullet(
        'Limit sugar intake to less than 10% of total energy intake (ideally below 5%, or roughly 25 grams for an adult), which applies to free sugars added to foods and drinks, as well as sugars naturally present in honey, syrups, fruit juices and fruit juice concentrates.',
      ),
      CareBlock.bullet(
        'Keep salt intake to less than 5 grams per day (equivalent to about one teaspoon) and use iodized salt.',
      ),
    ],
  ),
  CareTopic(
    title: 'Exercise Routines',
    subtitle: 'DAILY EXERCISE ROUTINE',
    icon: Icons.fitness_center,
    blocks: [
      CareBlock.bullet(
        'Adults (18–64 years): Do at least 150–300 minutes of moderate-intensity aerobic activity, or 75–150 minutes of vigorous-intensity aerobic activity, throughout the week.',
      ),
      CareBlock.bullet(
        'Muscle-Strengthening: Incorporate moderate- or greater-intensity muscle-strengthening activities involving all major muscle groups on 2 or more days a week, as these provide additional health benefits.',
      ),
      CareBlock.bullet(
        'Older Adults (65+ years): Follow the same aerobic and strength guidelines as younger adults, with an added emphasis on varied, multicomponent physical activity that prioritizes functional balance and strength training on 3 or more days a week to prevent falls.',
      ),
      CareBlock.bullet(
        'Children and Adolescents (aged 5–17 years): Average 60 minutes per day of moderate-to-vigorous intensity physical activity, mostly aerobic, across the week. Incorporate vigorous-intensity aerobic activities, as well as those that strengthen muscle and bone, at least 3 days a week.',
      ),
      CareBlock.bullet(
        'Limit Sedentary Behavior: Replace sedentary time with physical activity of any intensity, as being physically active helps reduce the detrimental health effects of high levels of sitting.',
      ),
    ],
  ),
  CareTopic(
    title: 'Stress Management',
    subtitle: 'STRESS COPING MANAGEMENT TIPS',
    icon: Icons.self_improvement,
    blocks: [
      CareBlock.paragraph(
        'The World Health Organization (WHO) explains that stress is a normal reaction to difficult challenges, but too much of it hurts your health. The WHO recommends these quick steps:',
      ),
      CareBlock.bullet(
        'Ground yourself: Focus on the present moment when thoughts race.',
      ),
      CareBlock.bullet(
        'Unhook from worries: Notice stressful thoughts without letting them control you.',
      ),
      CareBlock.bullet(
        'Act on what matters: Let your core values guide your actions, even under pressure.',
      ),
      CareBlock.bullet(
        'Be kind to yourself: Practice patience and self-compassion.',
      ),
      CareBlock.bullet(
        'Keep daily routines: Stick to consistent sleep, eating, and activity schedules.',
      ),
      CareBlock.bullet(
        'Stay connected: Talk to friends and family for support.',
      ),
      CareBlock.bullet(
        'Limit media overload: Take breaks from stressful news.',
      ),
      CareBlock.paragraph(
        'If stress becomes overwhelming, reach out to a trusted healthcare professional for support.',
      ),
    ],
  ),
  CareTopic(
    title: 'Sleep Hygiene',
    subtitle: 'HABITS THAT WILL HELP YOU REST',
    icon: Icons.bed,
    blocks: [
      CareBlock.paragraph(
        'The World Health Organization (WHO) emphasizes sleep as a vital pillar of health, supporting immune function, mental wellness, and cognitive recovery.',
      ),
      CareBlock.heading('Core Principles:'),
      CareBlock.bullet(
        'Consistency: Maintain fixed wake-up and sleep times to regulate circadian rhythms.',
      ),
      CareBlock.bullet(
        'Environment: Keep bedrooms dark, quiet, and comfortable.',
      ),
      CareBlock.bullet(
        'Lifestyle: Exercise regularly, avoid caffeine and heavy meals close to bedtime, and limit alcohol and tobacco.',
      ),
      CareBlock.heading('WHO Sleep Duration Guidelines for Young Children:'),
      CareBlock.bullet(
        'Newborns (0–3 months): 14 to 17 hours (with safe back-sleeping practices).',
      ),
      CareBlock.bullet(
        'Infants (4–11 months): 12 to 16 hours, including naps.',
      ),
      CareBlock.bullet('Toddlers (1–2 years): 11 to 14 hours, including naps.'),
      CareBlock.bullet(
        'Young Children (3–4 years): 10 to 13 hours, with reduced screen time and active daily play.',
      ),
    ],
  ),
  CareTopic(
    title: 'Hydration Management',
    subtitle: 'ACTIVE BALANCE OF FLUID INTAKE AND LOSS',
    icon: Icons.local_drink,
    blocks: [
      CareBlock.paragraph(
        'World Health Organization (WHO) hydration management centers on oral rehydration therapy (ORT), categorizing treatment into three distinct clinical plans:',
      ),
      CareBlock.bullet(
        'Plan A (No Dehydration): Increase fluid intake at home, continue feeding, and administer 10 to 20 mg of elemental zinc daily for 10 to 14 days.',
      ),
      CareBlock.bullet(
        'Plan B (Some Dehydration): Administer 75 mL/kg of low-osmolarity Oral Rehydration Salts (ORS) over a 4-hour period in a healthcare setting.',
      ),
      CareBlock.bullet(
        'Plan C (Severe Dehydration): Initiate rapid intravenous fluid resuscitation (Ringer\'s Lactate) immediately, transitioning to oral ORS (5 mL/kg/hour) as soon as the patient can drink.',
      ),
    ],
  ),
  CareTopic(
    title: 'Weight Management Tips',
    subtitle: 'KEEP HEALTHY BODY WEIGHT',
    icon: Icons.monitor_weight,
    blocks: [
      CareBlock.paragraph(
        'The World Health Organization (WHO) recommends a lifelong approach to weight management focusing on a balanced diet and regular physical activity:',
      ),
      CareBlock.bullet(
        'Improve Diet Quality: Limit total fat intake to under 30% of total energy, prioritizing unsaturated fats (like plant oils, fish, and nuts) over saturated and trans fats.',
      ),
      CareBlock.bullet(
        'Cut Sugars and Salt: Reduce free sugars to less than 10% (ideally under 5%) of daily energy intake and limit sodium.',
      ),
      CareBlock.bullet(
        'Increase Plant-Based Foods: Eat at least 400 grams (5 portions) of fruits, vegetables, whole grains, and legumes (lentils, beans) daily.',
      ),
      CareBlock.bullet(
        'Stay Physically Active: Adults should aim for at least 150 to 300 minutes of moderate-intensity aerobic activity per week (or equivalent vigorous activity) to prevent unhealthy weight gain.',
      ),
      CareBlock.bullet(
        'Reduce Sedentary Time: Limit prolonged sitting and screen time for both adults and children.',
      ),
    ],
  ),
];
