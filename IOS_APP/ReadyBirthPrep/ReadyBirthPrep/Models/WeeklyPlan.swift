import Foundation

// MARK: - Weekly Plan Models

struct WeeklyPlan: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var weekNumber: Int
    var trimester: Int
    var startDate: Date
    var endDate: Date
    var exerciseDays: [ExerciseDay]
    var nutritionGoals: [NutritionGoal]
    var educationTopics: [EducationTopic]
    var selfCareActivities: [SelfCareActivity]
    var preparationTasks: [PreparationTask]
    var symptoms: [SymptomManagement]
    var providerReminders: [ProviderReminder]
    var personalNotes: String?
    var isCompleted: Bool = false
    var completionRate: Double = 0.0
    
    init(userId: UUID, weekNumber: Int) {
        self.id = UUID()
        self.userId = userId
        self.weekNumber = weekNumber
        self.trimester = WeeklyPlan.getTrimester(from: weekNumber)
        
        // Calculate week dates
        let calendar = Calendar.current
        self.startDate = Date()
        self.endDate = calendar.date(byAdding: .day, value: 7, to: startDate) ?? Date()
        
        // Initialize with week-specific content
        self.exerciseDays = WeeklyPlan.getExerciseDays(for: weekNumber, trimester: self.trimester)
        self.nutritionGoals = WeeklyPlan.getNutritionGoals(for: weekNumber)
        self.educationTopics = WeeklyPlan.getEducationTopics(for: weekNumber)
        self.selfCareActivities = WeeklyPlan.getSelfCareActivities(for: weekNumber)
        self.preparationTasks = WeeklyPlan.getPreparationTasks(for: weekNumber)
        self.symptoms = WeeklyPlan.getSymptomManagement(for: weekNumber)
        self.providerReminders = WeeklyPlan.getProviderReminders(for: weekNumber)
    }
}

struct ExerciseDay: Codable, Identifiable {
    let id: UUID = UUID()
    var dayNumber: Int // 1, 2, or 3
    var exercises: [WeeklyExercise]
    var totalDuration: Int // in minutes
    var isCompleted: Bool = false
    var completedDate: Date?
    var lastAccessedDate: Date?
    
    var displayName: String {
        return "Day \(dayNumber)"
    }
}

struct WeeklyExercise: Codable, Identifiable {
    let id: UUID = UUID()
    var name: String
    var category: WeeklyExerciseCategory
    var duration: Int // in minutes
    var sets: Int = 1
    var reps: String? // e.g., "10-15" or "Hold for 30 seconds"
    var intensity: IntensityLevel
    var instructions: String
    var modifications: [String]
    var contraindications: [String]
    var videoUrl: String?
    var isCompleted: Bool = false
}

enum WeeklyExerciseCategory: String, Codable, CaseIterable {
    case cardio = "Cardiovascular"
    case strength = "Strength Training"
    case flexibility = "Flexibility & Stretching"
    case pelvicFloor = "Pelvic Floor"
    case breathing = "Breathing Exercises"
    case laborPrep = "Labor Preparation"
    case postural = "Postural Exercises"
}

enum IntensityLevel: String, Codable, CaseIterable {
    case gentle = "Gentle"
    case light = "Light"
    case moderate = "Moderate"
    case vigorous = "Vigorous"
}

struct NutritionGoal: Codable, Identifiable {
    let id: UUID = UUID()
    var category: NutritionCategory
    var goal: String
    var targetAmount: String?
    var foods: [String]
    var tips: [String]
    var isAchieved: Bool = false
}

enum NutritionCategory: String, Codable, CaseIterable {
    case calories = "Caloric Intake"
    case protein = "Protein"
    case iron = "Iron"
    case calcium = "Calcium"
    case folicAcid = "Folic Acid"
    case omega3 = "Omega-3"
    case hydration = "Hydration"
    case fiber = "Fiber"
    case vitamins = "Vitamins"
}

struct EducationTopic: Codable, Identifiable {
    let id: UUID = UUID()
    var title: String
    var category: EducationCategory
    var description: String
    var keyPoints: [String]
    var resources: [String]
    var estimatedReadTime: Int // in minutes
    var isCompleted: Bool = false
}

enum EducationCategory: String, Codable, CaseIterable {
    case fetalDevelopment = "Fetal Development"
    case bodyChanges = "Body Changes"
    case laborPreparation = "Labor Preparation"
    case newbornCare = "Newborn Care"
    case breastfeeding = "Breastfeeding"
    case postpartumRecovery = "Postpartum Recovery"
    case safety = "Safety & Warning Signs"
    case emotionalWellbeing = "Emotional Wellbeing"
}

struct SelfCareActivity: Codable, Identifiable {
    let id: UUID = UUID()
    var name: String
    var category: SelfCareCategory
    var duration: Int // in minutes
    var instructions: String
    var benefits: [String]
    var frequency: String
    var isCompleted: Bool = false
}

enum SelfCareCategory: String, Codable, CaseIterable {
    case relaxation = "Relaxation"
    case skinCare = "Skin Care"
    case sleep = "Sleep Hygiene"
    case mentalHealth = "Mental Health"
    case bonding = "Baby Bonding"
    case comfort = "Comfort Measures"
}

struct PreparationTask: Codable, Identifiable {
    let id: UUID = UUID()
    var title: String
    var category: PrepCategory
    var description: String
    var priority: TaskPriority
    var dueByWeek: Int?
    var checklist: [String]
    var isCompleted: Bool = false
}

enum PrepCategory: String, Codable, CaseIterable {
    case medical = "Medical Appointments"
    case babyGear = "Baby Gear"
    case nursery = "Nursery Preparation"
    case hospital = "Hospital Preparation"
    case documents = "Documents & Insurance"
    case classes = "Classes & Education"
    case postpartum = "Postpartum Planning"
}

enum TaskPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
}

struct SymptomManagement: Codable, Identifiable {
    let id: UUID = UUID()
    var symptom: String
    var commonInWeek: Bool
    var managementTips: [String]
    var warningSignsToWatch: [String]
    var whenToCallProvider: String?
}

struct ProviderReminder: Codable, Identifiable {
    let id: UUID = UUID()
    var reminderType: ReminderType
    var title: String
    var description: String
    var scheduledForWeek: Int?
    var isCompleted: Bool = false
    var completedDate: Date?
}

enum ReminderType: String, Codable, CaseIterable {
    case appointment = "Provider Appointment"
    case test = "Lab Test"
    case ultrasound = "Ultrasound"
    case vaccination = "Vaccination"
    case screening = "Screening"
    case other = "Other"
}

// MARK: - Weekly Plan Content Generation
extension WeeklyPlan {
    static func getTrimester(from week: Int) -> Int {
        if week <= 12 {
            return 1
        } else if week <= 27 {
            return 2
        } else {
            return 3
        }
    }
    
    static func getExerciseDays(for week: Int, trimester: Int) -> [ExerciseDay] {
        var exerciseDays: [ExerciseDay] = []
        
        // Create 3 exercise days per week
        
        // First Trimester (Weeks 1-12)
        if trimester == 1 {
            // Day 1: Focus on cardio and pelvic floor
            exerciseDays.append(ExerciseDay(
                dayNumber: 1,
                exercises: [
                    WeeklyExercise(
                        name: "Prenatal Walking",
                        category: .cardio,
                        duration: 20,
                        sets: 1,
                        reps: nil,
                        intensity: .light,
                        instructions: "Walk at a comfortable pace on flat, even surfaces. Listen to your body and slow down if needed.",
                        modifications: ["Can break into 10-minute sessions", "Use treadmill if weather is poor"],
                        contraindications: ["Vaginal bleeding", "Severe nausea", "Dizziness"]
                    ),
                    WeeklyExercise(
                        name: "Kegel Exercises",
                        category: .pelvicFloor,
                        duration: 10,
                        sets: 3,
                        reps: "10 reps (5 sec hold, 5 sec relax)",
                        intensity: .gentle,
                        instructions: "Contract pelvic floor muscles for 5 seconds, then relax for 5 seconds.",
                        modifications: ["Start with 3-second holds if 5 is too difficult"],
                        contraindications: []
                    )
                ],
                totalDuration: 30
            ))
            
            // Day 2: Focus on flexibility and core
            exerciseDays.append(ExerciseDay(
                dayNumber: 2,
                exercises: [
                    WeeklyExercise(
                        name: "Modified Yoga Flow",
                        category: .flexibility,
                        duration: 15,
                        sets: 1,
                        reps: nil,
                        intensity: .gentle,
                        instructions: "Focus on gentle stretches avoiding deep twists and inversions.",
                        modifications: ["Use props for support", "Skip any uncomfortable positions"],
                        contraindications: ["Avoid hot yoga", "Skip inversions"]
                    ),
                    WeeklyExercise(
                        name: "Pelvic Tilts",
                        category: .postural,
                        duration: 10,
                        sets: 2,
                        reps: "10-15 reps",
                        intensity: .gentle,
                        instructions: "Lie on back or stand against wall. Tilt pelvis to flatten lower back, hold briefly, then release.",
                        modifications: ["Can do seated if lying is uncomfortable"],
                        contraindications: []
                    ),
                    WeeklyExercise(
                        name: "Deep Breathing",
                        category: .breathing,
                        duration: 5,
                        sets: 1,
                        reps: "10 deep breaths",
                        intensity: .gentle,
                        instructions: "Practice diaphragmatic breathing, expanding belly on inhale.",
                        modifications: ["Can do in any comfortable position"],
                        contraindications: []
                    )
                ],
                totalDuration: 30
            ))
            
            // Day 3: Focus on strength and endurance
            exerciseDays.append(ExerciseDay(
                dayNumber: 3,
                                exercises: [
                    WeeklyExercise(
                        name: "Wall Push-Ups",
                        category: .strength,
                        duration: 10,
                        sets: 2,
                        reps: "10-12 reps",
                        intensity: .light,
                        instructions: "Stand arm's length from wall, push against wall keeping body straight.",
                        modifications: ["Adjust angle for difficulty", "Can do on knees if needed"],
                        contraindications: []
                    ),
                    WeeklyExercise(
                        name: "Standing Marches",
                        category: .cardio,
                        duration: 10,
                        sets: 1,
                        reps: nil,
                        intensity: .light,
                        instructions: "March in place, lifting knees comfortably high.",
                        modifications: ["Hold chair for balance", "Reduce knee height if needed"],
                        contraindications: ["Pelvic pain", "Balance issues"]
                    ),
                    WeeklyExercise(
                        name: "Side-Lying Leg Lifts",
                        category: .strength,
                        duration: 10,
                        sets: 2,
                        reps: "10 reps each side",
                        intensity: .light,
                        instructions: "Lie on side, lift top leg up and down slowly.",
                        modifications: ["Bend bottom leg for stability", "Use pillow between knees"],
                        contraindications: []
                    )
                ],
                totalDuration: 30
            ))
        }
        
        // Second Trimester (Weeks 13-27)
        else if trimester == 2 {
            // Day 1: Water exercises and pelvic floor
            exerciseDays.append(ExerciseDay(
                dayNumber: 1,
                                exercises: [
                    WeeklyExercise(
                        name: "Swimming or Water Walking",
                        category: .cardio,
                        duration: 25,
                        sets: 1,
                        reps: nil,
                        intensity: .moderate,
                        instructions: "Swim or walk in water. The buoyancy reduces joint stress while providing resistance.",
                        modifications: ["Use pool noodles for support", "Stay in shallow water if needed"],
                        contraindications: ["Ruptured membranes", "Cervical insufficiency"]
                    ),
                    WeeklyExercise(
                        name: "Standing Pelvic Floor Exercises",
                        category: .pelvicFloor,
                        duration: 10,
                        sets: 3,
                        reps: "10-15 reps",
                        intensity: .gentle,
                        instructions: "Contract and lift pelvic floor muscles while standing.",
                        modifications: ["Can do seated", "Coordinate with breathing"],
                        contraindications: []
                    )
                ],
                totalDuration: 35
            ))
            
            // Day 2: Strength and flexibility
            exerciseDays.append(ExerciseDay(
                dayNumber: 2,
                                exercises: [
                    WeeklyExercise(
                        name: "Prenatal Strength Circuit",
                        category: .strength,
                        duration: 20,
                        sets: 2,
                        reps: "12-15 reps each exercise",
                        intensity: .light,
                        instructions: "Circuit: squats, arm curls, shoulder presses with light weights (5-8 lbs).",
                        modifications: ["Use resistance bands", "Perform seated versions"],
                        contraindications: ["Avoid lying flat on back"]
                    ),
                    WeeklyExercise(
                        name: "Cat-Cow Stretches",
                        category: .postural,
                        duration: 10,
                        sets: 2,
                        reps: "10 slow movements",
                        intensity: .gentle,
                        instructions: "On hands and knees, alternate between arching and rounding your back.",
                        modifications: ["Use pillows under knees", "Can do standing with hands on thighs"],
                        contraindications: ["Wrist pain - use forearms"]
                    ),
                    WeeklyExercise(
                        name: "Hip Circles",
                        category: .flexibility,
                        duration: 5,
                        sets: 1,
                        reps: "10 circles each direction",
                        intensity: .gentle,
                        instructions: "Stand and make slow circles with hips.",
                        modifications: ["Hold chair for support", "Can do on birthing ball"],
                        contraindications: []
                    )
                ],
                totalDuration: 35
            ))
            
            // Day 3: Cardio and balance
            exerciseDays.append(ExerciseDay(
                dayNumber: 3,
                                exercises: [
                    WeeklyExercise(
                        name: "Stationary Cycling",
                        category: .cardio,
                        duration: 20,
                        sets: 1,
                        reps: nil,
                        intensity: .moderate,
                        instructions: "Cycle at comfortable pace, maintaining conversation ability.",
                        modifications: ["Adjust seat height", "Use recumbent bike if more comfortable"],
                        contraindications: ["Balance issues", "Pelvic pain"]
                    ),
                    WeeklyExercise(
                        name: "Standing Balance Exercises",
                        category: .postural,
                        duration: 10,
                        sets: 2,
                        reps: "Hold 30 seconds each",
                        intensity: .light,
                        instructions: "Practice single-leg stands, heel-to-toe walking.",
                        modifications: ["Hold wall or chair", "Keep both feet on ground if needed"],
                        contraindications: []
                    ),
                    WeeklyExercise(
                        name: "Prenatal Plank",
                        category: .strength,
                        duration: 5,
                        sets: 3,
                        reps: "Hold 20-30 seconds",
                        intensity: .moderate,
                        instructions: "Modified plank on knees or standing plank against wall.",
                        modifications: ["Wall plank for less intensity", "Knee plank on soft surface"],
                        contraindications: ["Diastasis recti", "Wrist pain"]
                    )
                ],
                totalDuration: 35
            ))
        }
        
        // Third Trimester (Weeks 28-40)
        else {
            // Day 1: Labor preparation
            exerciseDays.append(ExerciseDay(
                dayNumber: 1,
                                exercises: [
                    WeeklyExercise(
                        name: "Birthing Ball Exercises",
                        category: .laborPrep,
                        duration: 20,
                        sets: 1,
                        reps: nil,
                        intensity: .gentle,
                        instructions: "Sit on ball: hip circles, figure-8s, gentle bouncing, and pelvic rocks.",
                        modifications: ["Hold wall for stability", "Partner support"],
                        contraindications: ["Severe pelvic pain", "Risk of preterm labor"]
                    ),
                    WeeklyExercise(
                        name: "Labor Breathing Practice",
                        category: .breathing,
                        duration: 15,
                        sets: 1,
                        reps: nil,
                        intensity: .gentle,
                        instructions: "Practice different breathing patterns: slow breathing, light breathing, and transition breathing.",
                        modifications: ["Any comfortable position", "Use visualization"],
                        contraindications: []
                    )
                ],
                totalDuration: 35
            ))
            
            // Day 2: Gentle movement and flexibility
            exerciseDays.append(ExerciseDay(
                dayNumber: 2,
                                exercises: [
                    WeeklyExercise(
                        name: "Prenatal Walking",
                        category: .cardio,
                        duration: 15,
                        sets: 1,
                        reps: nil,
                        intensity: .light,
                        instructions: "Gentle walk at comfortable pace. Focus on posture and breathing.",
                        modifications: ["Shorter duration", "Indoor walking", "Rest as needed"],
                        contraindications: ["Contractions", "Leaking fluid"]
                    ),
                    WeeklyExercise(
                        name: "Hip Opening Stretches",
                        category: .flexibility,
                        duration: 15,
                        sets: 1,
                        reps: "Hold 30-60 seconds each",
                        intensity: .gentle,
                        instructions: "Butterfly stretch, supported squat, and side lunges.",
                        modifications: ["Use props", "Wall support for squats"],
                        contraindications: ["Pubic symphysis pain"]
                    ),
                    WeeklyExercise(
                        name: "Perineal Preparation",
                        category: .laborPrep,
                        duration: 10,
                        sets: 1,
                        reps: nil,
                        intensity: .gentle,
                        instructions: "Gentle perineal massage and relaxation exercises.",
                        modifications: ["Partner assistance", "Use mirror"],
                        contraindications: ["Active infections", "Placenta previa"]
                    )
                ],
                totalDuration: 40
            ))
            
            // Day 3: Comfort and relaxation
            exerciseDays.append(ExerciseDay(
                dayNumber: 3,
                                exercises: [
                    WeeklyExercise(
                        name: "Water Therapy",
                        category: .cardio,
                        duration: 20,
                        sets: 1,
                        reps: nil,
                        intensity: .gentle,
                        instructions: "Float, gentle swimming, or water walking for comfort.",
                        modifications: ["Just float if tired", "Warm water preferred"],
                        contraindications: ["Ruptured membranes"]
                    ),
                    WeeklyExercise(
                        name: "Labor Positions Practice",
                        category: .laborPrep,
                        duration: 15,
                        sets: 1,
                        reps: nil,
                        intensity: .gentle,
                        instructions: "Practice various labor positions: hands and knees, side-lying, supported squat.",
                        modifications: ["Use pillows", "Partner support"],
                        contraindications: []
                    ),
                    WeeklyExercise(
                        name: "Relaxation Sequence",
                        category: .breathing,
                        duration: 10,
                        sets: 1,
                        reps: nil,
                        intensity: .gentle,
                        instructions: "Progressive muscle relaxation with breathing exercises.",
                        modifications: ["Any comfortable position"],
                        contraindications: []
                    )
                ],
                totalDuration: 45
            ))
        }
        
        return exerciseDays
    }
    
    static func getNutritionGoals(for week: Int) -> [NutritionGoal] {
        var goals: [NutritionGoal] = []
        
        // Base nutrition goals for all trimesters
        goals.append(NutritionGoal(
            category: .hydration,
            goal: "Drink 8-10 glasses of water daily",
            targetAmount: "64-80 oz",
            foods: ["Water", "Herbal teas", "Water-rich fruits"],
            tips: ["Keep water bottle handy", "Add lemon for flavor", "Set hourly reminders"]
        ))
        
        goals.append(NutritionGoal(
            category: .folicAcid,
            goal: "Consume 400-800mcg of folic acid daily",
            targetAmount: "400-800mcg",
            foods: ["Leafy greens", "Fortified cereals", "Citrus fruits", "Beans"],
            tips: ["Take prenatal vitamin", "Eat folate-rich foods", "Avoid overcooking vegetables"]
        ))
        
        // Trimester-specific goals
        if week <= 12 {
            goals.append(NutritionGoal(
                category: .calories,
                goal: "Maintain regular caloric intake",
                targetAmount: "No additional calories needed",
                foods: ["Whole grains", "Lean proteins", "Fruits", "Vegetables"],
                tips: ["Eat small frequent meals for nausea", "Keep crackers by bedside"]
            ))
        } else if week <= 27 {
            goals.append(NutritionGoal(
                category: .calories,
                goal: "Add 340 extra calories daily",
                targetAmount: "+340 calories",
                foods: ["Nut butters", "Avocados", "Whole grain snacks"],
                tips: ["Choose nutrient-dense foods", "Healthy snacks between meals"]
            ))
            
            goals.append(NutritionGoal(
                category: .calcium,
                goal: "Get 1000mg calcium daily",
                targetAmount: "1000mg",
                foods: ["Dairy products", "Fortified plant milks", "Leafy greens", "Almonds"],
                tips: ["Pair with vitamin D for absorption", "Space throughout day"]
            ))
        } else {
            goals.append(NutritionGoal(
                category: .calories,
                goal: "Add 450 extra calories daily",
                targetAmount: "+450 calories",
                foods: ["Protein smoothies", "Trail mix", "Whole grain pasta"],
                tips: ["Focus on quality over quantity", "Prepare healthy snacks in advance"]
            ))
            
            goals.append(NutritionGoal(
                category: .iron,
                goal: "Get 27mg iron daily",
                targetAmount: "27mg",
                foods: ["Lean red meat", "Spinach", "Fortified cereals", "Beans"],
                tips: ["Combine with vitamin C foods", "Avoid tea with meals"]
            ))
        }
        
        return goals
    }
    
    static func getEducationTopics(for week: Int) -> [EducationTopic] {
        var topics: [EducationTopic] = []
        
        // Week-specific fetal development
        topics.append(EducationTopic(
            title: "Your Baby at Week \(week)",
            category: .fetalDevelopment,
            description: getFetalDevelopmentDescription(for: week),
            keyPoints: getFetalDevelopmentKeyPoints(for: week),
            resources: ["March of Dimes", "Mayo Clinic"],
            estimatedReadTime: 10
        ))
        
        // Trimester-specific topics
        if week <= 12 {
            topics.append(EducationTopic(
                title: "Managing Morning Sickness",
                category: .bodyChanges,
                description: "Understanding and managing nausea and vomiting in early pregnancy",
                keyPoints: [
                    "Eat small, frequent meals",
                    "Keep crackers by bedside",
                    "Stay hydrated with small sips",
                    "Avoid trigger foods and smells"
                ],
                resources: ["ACOG Guidelines", "Cleveland Clinic"],
                estimatedReadTime: 15
            ))
            
            if week >= 10 {
                topics.append(EducationTopic(
                    title: "Prenatal Testing Options",
                    category: .safety,
                    description: "Understanding available prenatal screening and diagnostic tests",
                    keyPoints: [
                        "First trimester screening",
                        "Cell-free DNA testing",
                        "Nuchal translucency ultrasound",
                        "Discuss options with provider"
                    ],
                    resources: ["ACOG", "Genetic Counseling"],
                    estimatedReadTime: 20
                ))
            }
        } else if week <= 27 {
            topics.append(EducationTopic(
                title: "Recognizing Baby's Movements",
                category: .fetalDevelopment,
                description: "Understanding fetal movement patterns and kick counts",
                keyPoints: [
                    "First movements felt around 18-22 weeks",
                    "Movements become more regular",
                    "Track patterns, not just counts",
                    "Report significant changes"
                ],
                resources: ["Count the Kicks", "ACOG"],
                estimatedReadTime: 10
            ))
            
            if week >= 20 {
                topics.append(EducationTopic(
                    title: "Anatomy Scan Information",
                    category: .safety,
                    description: "What to expect at your 20-week ultrasound",
                    keyPoints: [
                        "Detailed fetal anatomy check",
                        "Growth measurements",
                        "Placenta location",
                        "Option to learn baby's sex"
                    ],
                    resources: ["Radiology Info", "March of Dimes"],
                    estimatedReadTime: 15
                ))
            }
        } else {
            topics.append(EducationTopic(
                title: "Signs of Labor",
                category: .laborPreparation,
                description: "Recognizing true labor vs. false labor",
                keyPoints: [
                    "Regular contractions that strengthen",
                    "Water breaking signs",
                    "Bloody show",
                    "When to call provider"
                ],
                resources: ["ACOG Labor Guide", "Hospital Resources"],
                estimatedReadTime: 20
            ))
            
            if week >= 36 {
                topics.append(EducationTopic(
                    title: "Newborn Care Basics",
                    category: .newbornCare,
                    description: "Essential newborn care for the first days",
                    keyPoints: [
                        "Diaper changing techniques",
                        "Umbilical cord care",
                        "Safe sleep practices",
                        "Feeding cues"
                    ],
                    resources: ["AAP Guidelines", "La Leche League"],
                    estimatedReadTime: 25
                ))
            }
        }
        
        return topics
    }
    
    static func getSelfCareActivities(for week: Int) -> [SelfCareActivity] {
        var activities: [SelfCareActivity] = []
        
        // Universal self-care
        activities.append(SelfCareActivity(
            name: "Daily Affirmations",
            category: .mentalHealth,
            duration: 5,
            instructions: "Start your day with positive pregnancy affirmations",
            benefits: ["Reduces anxiety", "Promotes positive mindset", "Strengthens maternal bond"],
            frequency: "Daily"
        ))
        
        if week <= 12 {
            activities.append(SelfCareActivity(
                name: "Gentle Face Massage",
                category: .relaxation,
                duration: 10,
                instructions: "Use gentle circular motions to massage face and temples",
                benefits: ["Relieves tension", "Improves circulation", "Reduces headaches"],
                frequency: "As needed"
            ))
        } else if week <= 27 {
            activities.append(SelfCareActivity(
                name: "Belly Moisturizing Ritual",
                category: .skinCare,
                duration: 10,
                instructions: "Apply pregnancy-safe moisturizer or oil to growing belly",
                benefits: ["Prevents stretch marks", "Soothes itchy skin", "Bonding time with baby"],
                frequency: "Twice daily"
            ))
            
            activities.append(SelfCareActivity(
                name: "Partner Prenatal Bonding",
                category: .bonding,
                duration: 15,
                instructions: "Have partner talk or sing to baby, feel movements together",
                benefits: ["Strengthens family bond", "Baby recognizes voices", "Partner involvement"],
                frequency: "Several times per week"
            ))
        } else {
            activities.append(SelfCareActivity(
                name: "Labor Comfort Practice",
                category: .comfort,
                duration: 20,
                instructions: "Practice comfort measures like massage, positioning, breathing",
                benefits: ["Prepares for labor", "Reduces anxiety", "Builds confidence"],
                frequency: "2-3 times per week"
            ))
            
            activities.append(SelfCareActivity(
                name: "Nesting Meditation",
                category: .relaxation,
                duration: 15,
                instructions: "Guided meditation focusing on preparing your space and mind",
                benefits: ["Channels nesting energy", "Reduces stress", "Mental preparation"],
                frequency: "As desired"
            ))
        }
        
        return activities
    }
    
    static func getPreparationTasks(for week: Int) -> [PreparationTask] {
        var tasks: [PreparationTask] = []
        
        if week == 8 {
            tasks.append(PreparationTask(
                title: "Schedule First Prenatal Appointment",
                category: .medical,
                description: "Book your initial prenatal visit with chosen provider",
                priority: .urgent,
                dueByWeek: 10,
                checklist: ["Choose provider", "Verify insurance", "Prepare questions list"]
            ))
        }
        
        if week == 12 {
            tasks.append(PreparationTask(
                title: "Research Prenatal Classes",
                category: .classes,
                description: "Look into childbirth, breastfeeding, and newborn care classes",
                priority: .medium,
                dueByWeek: 20,
                checklist: ["Check hospital offerings", "Compare online options", "Review schedules"]
            ))
        }
        
        if week == 20 {
            tasks.append(PreparationTask(
                title: "Start Baby Registry",
                category: .babyGear,
                description: "Begin researching and registering for essential baby items",
                priority: .medium,
                dueByWeek: 28,
                checklist: ["Research car seats", "Compare cribs", "List essentials"]
            ))
        }
        
        if week == 28 {
            tasks.append(PreparationTask(
                title: "Tour Birth Facility",
                category: .hospital,
                description: "Schedule and complete tour of chosen birth location",
                priority: .high,
                dueByWeek: 32,
                checklist: ["Schedule tour", "Prepare questions", "Review policies"]
            ))
        }
        
        if week == 32 {
            tasks.append(PreparationTask(
                title: "Pack Hospital Bag",
                category: .hospital,
                description: "Prepare bags for labor, postpartum, and baby",
                priority: .high,
                dueByWeek: 36,
                checklist: ["Labor items", "Postpartum supplies", "Baby essentials", "Partner items"]
            ))
        }
        
        if week == 36 {
            tasks.append(PreparationTask(
                title: "Finalize Birth Plan",
                category: .documents,
                description: "Complete and discuss birth preferences with provider",
                priority: .urgent,
                dueByWeek: 37,
                checklist: ["Review preferences", "Discuss with provider", "Make copies"]
            ))
        }
        
        return tasks
    }
    
    static func getSymptomManagement(for week: Int) -> [SymptomManagement] {
        var symptoms: [SymptomManagement] = []
        
        if week <= 12 {
            symptoms.append(SymptomManagement(
                symptom: "Morning Sickness",
                commonInWeek: true,
                managementTips: [
                    "Eat small, frequent meals",
                    "Keep crackers by bedside",
                    "Try ginger tea or candies",
                    "Avoid strong smells"
                ],
                warningSignsToWatch: ["Unable to keep fluids down", "Weight loss", "Severe dehydration"],
                whenToCallProvider: "If vomiting more than 3 times daily or showing signs of dehydration"
            ))
            
            symptoms.append(SymptomManagement(
                symptom: "Fatigue",
                commonInWeek: true,
                managementTips: [
                    "Rest when possible",
                    "Go to bed earlier",
                    "Take short naps if needed",
                    "Gentle exercise can help"
                ],
                warningSignsToWatch: ["Extreme exhaustion", "Inability to function"],
                whenToCallProvider: "If fatigue is accompanied by shortness of breath or heart palpitations"
            ))
        } else if week <= 27 {
            symptoms.append(SymptomManagement(
                symptom: "Round Ligament Pain",
                commonInWeek: true,
                managementTips: [
                    "Change positions slowly",
                    "Support belly when coughing/sneezing",
                    "Warm compress on area",
                    "Prenatal yoga stretches"
                ],
                warningSignsToWatch: ["Severe abdominal pain", "Pain with bleeding", "Fever"],
                whenToCallProvider: "If pain is severe, constant, or accompanied by other symptoms"
            ))
        } else {
            symptoms.append(SymptomManagement(
                symptom: "Braxton Hicks Contractions",
                commonInWeek: true,
                managementTips: [
                    "Change positions",
                    "Walk around",
                    "Drink water",
                    "Empty bladder"
                ],
                warningSignsToWatch: ["Regular pattern", "Increasing intensity", "Back pain", "Pelvic pressure"],
                whenToCallProvider: "If contractions are regular (every 5-10 minutes) or painful"
            ))
        }
        
        return symptoms
    }
    
    static func getProviderReminders(for week: Int) -> [ProviderReminder] {
        var reminders: [ProviderReminder] = []
        
        // Standard appointment schedule
        if week == 8 {
            reminders.append(ProviderReminder(
                reminderType: .appointment,
                title: "First Prenatal Visit",
                description: "Comprehensive health history, physical exam, and initial labs",
                scheduledForWeek: 8
            ))
        }
        
        if week == 12 {
            reminders.append(ProviderReminder(
                reminderType: .screening,
                title: "First Trimester Screening",
                description: "Optional genetic screening and nuchal translucency ultrasound",
                scheduledForWeek: 12
            ))
        }
        
        if week == 20 {
            reminders.append(ProviderReminder(
                reminderType: .ultrasound,
                title: "Anatomy Scan",
                description: "Detailed ultrasound to check baby's development",
                scheduledForWeek: 20
            ))
        }
        
        if week == 24 {
            reminders.append(ProviderReminder(
                reminderType: .test,
                title: "Glucose Screening",
                description: "Test for gestational diabetes",
                scheduledForWeek: 24
            ))
        }
        
        if week == 28 {
            reminders.append(ProviderReminder(
                reminderType: .vaccination,
                title: "Tdap Vaccine",
                description: "Protects baby from whooping cough",
                scheduledForWeek: 28
            ))
        }
        
        if week == 36 {
            reminders.append(ProviderReminder(
                reminderType: .test,
                title: "Group B Strep Test",
                description: "Screening for GBS bacteria",
                scheduledForWeek: 36
            ))
        }
        
        return reminders
    }
    
    // Helper functions for fetal development content
    private static func getFetalDevelopmentDescription(for week: Int) -> String {
        switch week {
        case 1...4:
            return "Your baby is just beginning! The fertilized egg is implanting and starting to develop."
        case 5...8:
            return "Major organs are forming. The neural tube, which becomes the brain and spinal cord, is developing."
        case 9...12:
            return "Your baby is now a fetus! All major organs are formed and starting to function."
        case 13...16:
            return "Your baby is growing rapidly. Facial features are becoming more defined."
        case 17...20:
            return "You may start feeling movement! Baby is developing sleep/wake cycles."
        case 21...24:
            return "Your baby's senses are developing. They can hear your voice and heartbeat."
        case 25...28:
            return "Brain development accelerates. Baby's eyes can open and close."
        case 29...32:
            return "Baby is gaining weight rapidly. Bones are hardening but skull remains soft."
        case 33...36:
            return "Baby's immune system is maturing. Most babies move to head-down position."
        case 37...40:
            return "Your baby is full-term! Final developments include lung maturation and fat accumulation."
        default:
            return "Your baby continues to grow and develop."
        }
    }
    
    private static func getFetalDevelopmentKeyPoints(for week: Int) -> [String] {
        switch week {
        case 4:
            return ["Size: Poppy seed", "Implantation occurring", "Placenta beginning to form"]
        case 8:
            return ["Size: Raspberry", "Heart beating", "Arms and legs forming"]
        case 12:
            return ["Size: Lime", "Can make sucking movements", "Reflexes developing"]
        case 16:
            return ["Size: Avocado", "Can hear sounds", "Hair beginning to grow"]
        case 20:
            return ["Size: Banana", "Halfway point!", "Gender visible on ultrasound"]
        case 24:
            return ["Size: Corn cob", "Lungs developing", "Responds to sounds"]
        case 28:
            return ["Size: Eggplant", "Eyes can open", "Dreams during REM sleep"]
        case 32:
            return ["Size: Squash", "Practicing breathing", "Bones hardening"]
        case 36:
            return ["Size: Honeydew", "Full-term soon", "Head engaging in pelvis"]
        case 40:
            return ["Size: Watermelon", "Ready for birth!", "Average 7.5 lbs"]
        default:
            return ["Growing steadily", "Developing new skills", "Preparing for life outside"]
        }
    }
}