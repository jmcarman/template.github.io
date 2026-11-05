# frozen_string_literal: true

require 'kramdown/converter/html'

module Kramdown
  module Converter
    module DivTableConverter
      ENTITY_NBSP = ::Kramdown::Utils::Entities.entity('nbsp')

      # Stack state at entry: el is :table (not yet pushed to @stack)
      def convert_table(el, indent)
        return super unless div_table_enabled?(el)

        col_count = el.options[:alignment]&.length || 1
        attr = build_div_attr(el.attr, 'md-table', 'role' => 'table')
        append_style!(attr, "--col-count: #{col_count}")

        format_as_indented_block_html('div', attr, inner(el, indent), indent)
      end

      # Stack state at entry: @stack[-1] is :table
      def convert_thead(el, indent)
        return super unless div_table_enabled?(@stack.last)

        attr = build_div_attr(el.attr, 'md-thead', 'role' => 'rowgroup')
        format_as_indented_block_html('div', attr, inner(el, indent), indent)
      end

      def convert_tbody(el, indent)
        return super unless div_table_enabled?(@stack.last)

        attr = build_div_attr(el.attr, 'md-tbody', 'role' => 'rowgroup')
        format_as_indented_block_html('div', attr, inner(el, indent), indent)
      end

      def convert_tfoot(el, indent)
        return super unless div_table_enabled?(@stack.last)

        attr = build_div_attr(el.attr, 'md-tfoot', 'role' => 'rowgroup')
        format_as_indented_block_html('div', attr, inner(el, indent), indent)
      end

      # Stack state at entry: @stack[-1] is :thead/:tbody/:tfoot, @stack[-2] is :table
      def convert_tr(el, indent)
        return super unless div_table_enabled?(@stack[-2])

        attr = build_div_attr(el.attr, 'md-tr', 'role' => 'row')
        format_as_indented_block_html('div', attr, inner(el, indent), indent)
      end

      # Stack state at entry: @stack[-1] is :tr, @stack[-2] is :thead/:tbody/:tfoot, @stack[-3] is :table
      def convert_td(el, indent)
        table_el = @stack[-3]
        return super unless div_table_enabled?(table_el)

        res = inner(el, indent)
        in_thead   = (@stack[-2].type == :thead)
        cell_class = in_thead ? 'md-th' : 'md-td'
        aria_role  = in_thead ? 'columnheader' : 'cell'

        attr = build_div_attr(el.attr, cell_class, 'role' => aria_role)

        col_idx   = @stack.last.children.index(el)
        alignment = table_el.options[:alignment][col_idx]
        append_style!(attr, "text-align: #{alignment}") if alignment && alignment != :default

        if !in_thead && (label = extract_column_label(table_el, col_idx))
          attr['data-label'] ||= label unless label.empty?
        end

        content = res.empty? ? entity_to_str(ENTITY_NBSP) : res
        format_as_block_html('div', attr, content, indent)
      end
      alias convert_th convert_td

      private

      # Converts all Markdown tables by default.
      # To make conversion opt-in via `{: .div-table}`, change to:
      #   table_el&.type == :table && table_el.attr['class']&.split&.include?('div-table')
      def div_table_enabled?(table_el)
        table_el && table_el.type == :table
      end

      def build_div_attr(orig_attr, base_class, extra = {})
        attr = orig_attr.dup
        existing = attr['class']&.split || []
        attr['class'] = (existing | [base_class]).join(' ')
        extra.each { |k, v| attr[k] ||= v }
        attr
      end

      def append_style!(attr, declaration)
        attr['style'] = [attr['style']&.chomp(';'), declaration].compact.reject(&:empty?).join('; ')
      end

      def extract_column_label(table_el, col_idx)
        thead = table_el.children.find { |c| c.type == :thead }
        header_cell = thead&.children&.first&.children&.[](col_idx)
        return nil unless header_cell

        inner(header_cell, 0).gsub(/<[^>]+>/, '').strip
      end
    end

    Html.prepend(DivTableConverter)
  end
end