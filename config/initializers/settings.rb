# Multiple Choice Questions
QUESTIONS = YAML::load_file('config/questions.yml')['questions']

# Bingo
BINGO = {:prompts => [], :responses => []}
BINGO[:all] = YAML::load_file('config/bingo.yml')['bingo'].each do |set|
  BINGO[:prompts] << set['prompt']
  BINGO[:responses] << set['response']
end
