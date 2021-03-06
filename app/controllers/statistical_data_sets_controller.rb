class StatisticalDataSetsController < DocumentsController
  def index
    statistical_data_sets = StatisticalDataSetPresenter.decorate(StatisticalDataSet.published)
    @alphabetically_grouped_data_sets = statistical_data_sets.group_by do |data_set|
      data_set.title.first.upcase
    end.sort
  end

  private

  def document_class
    StatisticalDataSet
  end
end