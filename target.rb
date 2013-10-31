#!/usr/bin/env ruby

require 'prawn'
require 'prawn/layout'
require 'prawn/measurement_extensions'

GRAY = '999999'
ORANGE = 'ffa500'
RED = 'ff0000'

BOXES_PER_INCH = 2

BOXES_PER_SIDE = 6 * BOXES_PER_INCH
BOXES_PER_BULL_SIDE = BOXES_PER_INCH
LINE_WIDTH = 1.pt
INCH_LINE_WIDTH = 3.pt
CROSSHAIR_LINE_WIDTH = 6.pt
BULL_COLOR = ORANGE

YARDS = [7, 10, 15, 25, 50, 100, 200, 300]

SPACING = (1.0/BOXES_PER_INCH).in
DELTA = (LINE_WIDTH / 2.0) # Take the width of the lines into account
SIDE_LENGTH = SPACING * BOXES_PER_SIDE
BULL_LENGTH = SPACING * BOXES_PER_BULL_SIDE

def moa_string yards
  boxes_per_moa = (yards / 100.0) * BOXES_PER_INCH
  moa_per_box = 1/boxes_per_moa
  if (moa_per_box.to_i > 0)
    if moa_per_box.round == 1
      '1 square per MOA' % yards
    else
      '%d MOA per square' % [moa_per_box.round, yards]
    end
  elsif (boxes_per_moa - boxes_per_moa.round).abs <= boxes_per_moa * 0.1
    '%d squares per MOA' % [boxes_per_moa.round, yards]
  else
    '%.1f squares per MOA' % [boxes_per_moa, yards]
  end
end

Prawn::Document.generate('target.pdf') do
  fill_color '777777'
  font_size 8.pt
  table(
    YARDS.map{ |yards| ['%d yards' % yards, moa_string(yards)] },
    cell_style: {
      border_color: '777777',
      padding: 3.pt,
    },
    position: :right
  )

  # ruler
  ruler_right = ((bounds.width - SIDE_LENGTH) / 2) + SIDE_LENGTH
  ruler_width = 1.in - LINE_WIDTH
  ruler_left = ruler_right - ruler_width
  ruler_y = ((bounds.height - SIDE_LENGTH) / 2) + SIDE_LENGTH + 8.pt

  stroke_color '999999'
  stroke_line [ruler_left, ruler_y], [ruler_right, ruler_y]
  stroke_line [ruler_left, ruler_y - 4.pt], [ruler_left, ruler_y + 4.pt]
  stroke_line [ruler_right, ruler_y - 4.pt], [ruler_right, ruler_y + 4.pt]

  fill_color '999999'
  bounding_box([ruler_left, ruler_y + 8.pt], width: ruler_width) do
    text '1"', align: :center
  end

  canvas do

    # target
    bounding_box(
      [
        DELTA + ((bounds.width - SIDE_LENGTH) / 2) - LINE_WIDTH,
        ((bounds.height + SIDE_LENGTH) / 2) + LINE_WIDTH,
      ],
      width: SIDE_LENGTH + LINE_WIDTH,
      height: SIDE_LENGTH + LINE_WIDTH,
    ) do
      # bull fill
      fill_color BULL_COLOR
      offset = DELTA + ((SIDE_LENGTH - BULL_LENGTH) / 2)
      fill_rectangle(
        [
          DELTA + ((SIDE_LENGTH - BULL_LENGTH) / 2),
          DELTA + ((SIDE_LENGTH + BULL_LENGTH) / 2),
        ],
        BULL_LENGTH,
        BULL_LENGTH,
      )

      # grid lines
      stroke_color '000000'
      stroke_bounds
      (1..(BOXES_PER_SIDE)-1).each do |i|
        if BOXES_PER_INCH > 1 && i % BOXES_PER_INCH == 0
          line_width INCH_LINE_WIDTH
        else
          line_width LINE_WIDTH
        end
        offset = (i * SPACING)
        stroke_line [offset, 0], [offset, bounds.height]
        stroke_line [0, offset], [bounds.width, offset]
      end

      # crosshair lines
      line_width CROSSHAIR_LINE_WIDTH
      offset = (BOXES_PER_SIDE / 2) * SPACING
      stroke_line [offset, 0], [offset, bounds.height]
      stroke_line [0, offset], [bounds.width, offset]
    end
  end
end
