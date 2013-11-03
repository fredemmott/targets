task :default => :examples

multitask :examples => [
  'examples/1_per_inch.pdf',
  'examples/2_per_inch.pdf',
  'examples/4_per_inch.pdf',
  'examples/8_per_inch.pdf',
]

rule(/^examples\/\d+_per_inch\.pdf$/) do |t|
  sh "./target --boxes-per-inch #{t.name[/\d+/]} --outfile #{t.name}"
end
