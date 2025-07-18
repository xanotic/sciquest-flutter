-- This is a new migration file to add more questions.
-- The filename should be something like: supabase/migrations/YYYYMMDDHHMMSS_add_more_questions.sql

-- IMPORTANT: If you have already run the previous `create_questions_table.sql`
-- from the PHP/MySQL context, you might need to manually clear your Supabase
-- `questions` table or reset your local Supabase database before applying this.
-- If you are starting fresh with Supabase local development, this script will
-- simply insert the data.

-- Delete existing questions to avoid duplicates if this is a re-run
-- REMOVED: DELETE FROM public.questions;

-- Insert dummy data for various categories (at least 5 questions per category)

-- Mathematics (5 questions)
INSERT INTO public.questions (question, options, correct_answer, category, subcategory, difficulty, explanation) VALUES
(
  'What is the value of pi (π) rounded to two decimal places?',
  '["3.10", "3.14", "3.16", "3.18"]',
  1,
  'Mathematics',
  'Geometry',
  'easy',
  'Pi (π) is approximately 3.14159, so rounded to two decimal places it is 3.14.'
),
(
  'Solve for x: 2x + 5 = 15',
  '["x = 5", "x = 10", "x = 7.5", "x = 2.5"]',
  0,
  'Mathematics',
  'Algebra',
  'easy',
  'Subtract 5 from both sides: 2x = 10. Then divide by 2: x = 5.'
),
(
  'What is the sum of the interior angles of a triangle?',
  '["90 degrees", "180 degrees", "270 degrees", "360 degrees"]',
  1,
  'Mathematics',
  'Geometry',
  'easy',
  'The sum of the interior angles of any triangle is always 180 degrees.'
),
(
  'If a car travels at 60 km/h for 3 hours, how far does it travel?',
  '["120 km", "150 km", "180 km", "200 km"]',
  2,
  'Mathematics',
  'Applied Math',
  'easy',
  'Distance = Speed × Time. So, 60 km/h × 3 h = 180 km.'
),
(
  'What is the next number in the Fibonacci sequence: 0, 1, 1, 2, 3, 5, 8, ...?',
  '["10", "11", "12", "13"]',
  3,
  'Mathematics',
  'Sequences',
  'medium',
  'In the Fibonacci sequence, each number is the sum of the two preceding ones. 5 + 8 = 13.'
);

-- Physics (5 questions)
INSERT INTO public.questions (question, options, correct_answer, category, subcategory, difficulty, explanation) VALUES
(
  'What is the SI unit of force?',
  '["Joule", "Watt", "Newton", "Pascal"]',
  2,
  'Physics',
  'Mechanics',
  'easy',
  'The Newton (N) is the SI unit of force, named after Isaac Newton.'
),
(
  'Which law states that for every action, there is an equal and opposite reaction?',
  '["Newton''s First Law", "Newton''s Second Law", "Newton''s Third Law", "Law of Conservation of Energy"]',
  2,
  'Physics',
  'Mechanics',
  'medium',
  'Newton''s Third Law of Motion describes action-reaction pairs.'
),
(
  'What is the speed of light in a vacuum (approximately)?',
  '["3 x 10^5 m/s", "3 x 10^8 m/s", "3 x 10^10 m/s", "3 x 10^12 m/s"]',
  1,
  'Physics',
  'Optics',
  'medium',
  'The speed of light in a vacuum is approximately 299,792,458 meters per second, often rounded to 3 x 10^8 m/s.'
),
(
  'What type of energy is stored in a stretched spring?',
  '["Kinetic energy", "Thermal energy", "Potential energy", "Chemical energy"]',
  2,
  'Physics',
  'Energy',
  'easy',
  'A stretched or compressed spring stores elastic potential energy.'
),
(
  'Which of the following is a scalar quantity?',
  '["Velocity", "Acceleration", "Force", "Mass"]',
  3,
  'Physics',
  'Mechanics',
  'hard',
  'Mass is a scalar quantity (only magnitude), while velocity, acceleration, and force are vector quantities (magnitude and direction).'
);

-- Chemistry (5 questions)
INSERT INTO public.questions (question, options, correct_answer, category, subcategory, difficulty, explanation) VALUES
(
  'What is the chemical symbol for water?',
  '["Wo", "Wa", "H2O", "O2"]',
  2,
  'Chemistry',
  'Basic Concepts',
  'easy',
  'Water is composed of two hydrogen atoms and one oxygen atom, hence H2O.'
),
(
  'Which gas do plants absorb from the atmosphere?',
  '["Oxygen", "Nitrogen", "Carbon Dioxide", "Hydrogen"]',
  2,
  'Chemistry',
  'Biochemistry',
  'easy',
  'Plants absorb carbon dioxide for photosynthesis.'
),
(
  'What is the pH of a neutral solution at 25°C?',
  '["0", "7", "14", "Depends on the solution"]',
  1,
  'Chemistry',
  'Acids and Bases',
  'medium',
  'A neutral solution, like pure water, has a pH of 7 at 25°C.'
),
(
  'Which element is a noble gas?',
  '["Oxygen", "Nitrogen", "Helium", "Chlorine"]',
  2,
  'Chemistry',
  'Periodic Table',
  'easy',
  'Helium is a noble gas, characterized by its full outer electron shell and low reactivity.'
),
(
  'What is the process by which a solid turns directly into a gas?',
  '["Melting", "Evaporation", "Condensation", "Sublimation"]',
  3,
  'Chemistry',
  'States of Matter',
  'medium',
  'Sublimation is the transition of a substance directly from the solid to the gas phase without passing through the liquid phase.'
);

-- Biology (5 questions)
INSERT INTO public.questions (question, options, correct_answer, category, subcategory, difficulty, explanation) VALUES
(
  'What is the powerhouse of the cell?',
  '["Nucleus", "Mitochondria", "Ribosome", "Endoplasmic Reticulum"]',
  1,
  'Biology',
  'Cell Biology',
  'easy',
  'Mitochondria are responsible for generating most of the cell''s supply of adenosine triphosphate (ATP), used as a source of chemical energy.'
),
(
  'Which of the following is a primary producer in most ecosystems?',
  '["Fungi", "Animals", "Plants", "Bacteria"]',
  2,
  'Biology',
  'Ecology',
  'easy',
  'Plants are primary producers as they convert light energy into chemical energy through photosynthesis.'
),
(
  'What is the main function of red blood cells?',
  '["Fighting infection", "Clotting blood", "Transporting oxygen", "Producing antibodies"]',
  2,
  'Biology',
  'Human Body',
  'medium',
  'Red blood cells contain hemoglobin, which binds to oxygen and transports it throughout the body.'
),
(
  'Which of these is a vertebrate?',
  '["Jellyfish", "Spider", "Fish", "Worm"]',
  2,
  'Biology',
  'Zoology',
  'easy',
  'Vertebrates are animals with a backbone or spinal column. Fish have a backbone.'
),
(
  'What is the process by which organisms adapt to their environment over time?',
  '["Metabolism", "Photosynthesis", "Evolution", "Respiration"]',
  2,
  'Biology',
  'Genetics & Evolution',
  'medium',
  'Evolution is the process of change in the heritable characteristics of biological populations over successive generations.'
);

-- Computer Science (5 questions)
INSERT INTO public.questions (question, options, correct_answer, category, subcategory, difficulty, explanation) VALUES
(
  'What does CPU stand for?',
  '["Central Processing Unit", "Computer Personal Unit", "Central Program Utility", "Control Processing Unit"]',
  0,
  'Computer Science',
  'Hardware',
  'easy',
  'CPU stands for Central Processing Unit, the "brain" of a computer.'
),
(
  'Which programming language is often used for web development and is known for its flexibility?',
  '["Java", "C++", "Python", "JavaScript"]',
  3,
  'Computer Science',
  'Programming',
  'medium',
  'JavaScript is widely used for front-end and back-end web development.'
),
(
  'What is an algorithm?',
  '["A type of computer virus", "A set of instructions to solve a problem", "A hardware component", "A database management system"]',
  1,
  'Computer Science',
  'Algorithms',
  'easy',
  'An algorithm is a step-by-step procedure for solving a problem or accomplishing a task.'
),
(
  'What is the purpose of a firewall?',
  '["To speed up internet connection", "To protect a network from unauthorized access", "To store data", "To display graphics"]',
  1,
  'Computer Science',
  'Networking',
  'medium',
  'A firewall acts as a barrier between a trusted internal network and untrusted external networks, controlling incoming and outgoing network traffic.'
),
(
  'In object-oriented programming, what is encapsulation?',
  '["The ability of an object to take on many forms", "The process of creating new objects", "Bundling data and methods that operate on the data within a single unit", "Hiding the implementation details of an object"]',
  2,
  'Computer Science',
  'OOP',
  'hard',
  'Encapsulation is the bundling of data (attributes) and methods (functions) that operate on the data into a single unit or class, and restricting direct access to some of an object''s components.'
);

-- Engineering (5 questions)
INSERT INTO public.questions (question, options, correct_answer, category, subcategory, difficulty, explanation) VALUES
(
  'Which type of engineer designs and builds roads, bridges, and buildings?',
  '["Mechanical Engineer", "Electrical Engineer", "Civil Engineer", "Chemical Engineer"]',
  2,
  'Engineering',
  'Civil Engineering',
  'easy',
  'Civil engineers are responsible for the design, construction, and maintenance of the physical and naturally built environment.'
),
(
  'What is the primary function of a gear in a mechanical system?',
  '["To generate electricity", "To store energy", "To transmit power and change speed/torque", "To measure temperature"]',
  2,
  'Engineering',
  'Mechanical Engineering',
  'medium',
  'Gears are used to transmit rotational motion and power, and to change the speed and torque between rotating parts.'
),
(
  'Which material is known for its excellent electrical conductivity?',
  '["Wood", "Rubber", "Copper", "Glass"]',
  2,
  'Engineering',
  'Electrical Engineering',
  'easy',
  'Copper is a highly conductive metal widely used in electrical wiring.'
),
(
  'What does CAD stand for in engineering design?',
  '["Computer Aided Design", "Central Analysis Data", "Calculated Architectural Drawing", "Computerized Assembly Diagram"]',
  0,
  'Engineering',
  'Design & Tools',
  'easy',
  'CAD (Computer-Aided Design) software is used by engineers and architects to create 2D and 3D designs.'
),
(
  'In structural engineering, what is a truss?',
  '["A type of foundation", "A framework of interconnected members forming a rigid structure", "A decorative architectural element", "A type of concrete mix"]',
  1,
  'Engineering',
  'Structural Engineering',
  'medium',
  'A truss is a structure comprising one or more triangular units constructed with straight members whose ends are connected at joints.'
);

-- Earth Science (5 questions)
INSERT INTO public.questions (question, options, correct_answer, category, subcategory, difficulty, explanation) VALUES
(
  'What is the outermost layer of the Earth called?',
  '["Mantle", "Core", "Crust", "Atmosphere"]',
  2,
  'Earth Science',
  'Geology',
  'easy',
  'The Earth''s crust is its outermost solid layer.'
),
(
  'Which natural phenomenon is measured on the Richter scale?',
  '["Tornadoes", "Hurricanes", "Earthquakes", "Volcanic eruptions"]',
  2,
  'Earth Science',
  'Geology',
  'easy',
  'The Richter scale is used to measure the magnitude of earthquakes.'
),
(
  'What is the process by which rocks are broken down into smaller pieces by natural forces?',
  '["Erosion", "Deposition", "Weathering", "Compaction"]',
  2,
  'Earth Science',
  'Geology',
  'medium',
  'Weathering is the process that breaks down rocks, soil, and minerals through contact with the Earth''s atmosphere, biota, and waters.'
),
(
  'Which gas makes up the majority of Earth''s atmosphere?',
  '["Oxygen", "Carbon Dioxide", "Nitrogen", "Argon"]',
  2,
  'Earth Science',
  'Atmospheric Science',
  'easy',
  'Nitrogen constitutes about 78% of Earth''s atmosphere.'
),
(
  'What is the name of the supercontinent that existed before the continents drifted apart?',
  '["Gondwana", "Laurasia", "Pangaea", "Rodinia"]',
  2,
  'Earth Science',
  'Plate Tectonics',
  'medium',
  'Pangaea was a supercontinent that existed during the late Paleozoic and early Mesozoic eras.'
);
