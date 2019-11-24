@AbapCatalog.sqlViewName: 'ZXRMV_0001'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'view to existing app elements'
define view zxrmv_app_element
  as select from zxrm_entity
{
  'entity    '                       as type,
  '514822a4fccc4a9c8c398a0ae8ddc8de' as project_id,
  zxrm_entity.id,
  zxrm_entity.name
}
union select from zxrm_project
{
  'project'                          as type,
  '514822a4fccc4a9c8c398a0ae8ddc8de' as project_id,
  zxrm_project.id,
  zxrm_project.name
}
