module.exports = ->
  schemaVersion: 2
  "-enableQuickSwitch": false
  "-refreshOnProfileChange": true
  "-startupProfileName": ""
  "-quickSwitchProfiles": []
  "-revertProxyChanges": true
  "-confirmDeletion": true
  "-showInspectMenu": true
  "-addConditionsToBottom": false
  "-showResultProfileOnActionBadgeText": false
  "-showExternalProfile": true
  "-downloadInterval": 1440
  "+v2rayN":
    profileType: "FixedProfile"
    name: "v2rayN"
    color: "#99ccee"
    fallbackProxy:
      port: 10809
      scheme: "http"
      host: "127.0.0.1"
    proxyForSocks:
      port: 10808
      scheme: "socks5"
      host: "127.0.0.1"
    bypassList: [
      {
        pattern: "127.0.0.1"
        conditionType: "BypassCondition"
      }
      {
        pattern: "::1"
        conditionType: "BypassCondition"
      }
      {
        pattern: "localhost"
        conditionType: "BypassCondition"
      }
      {
        pattern: "<local>"
        conditionType: "BypassCondition"
      }
    ]

  "+__ruleListOf_auto switch":
    profileType: "RuleListProfile"
    name: "__ruleListOf_auto switch"
    color: "#99dd99"
    format: "AutoProxy"
    sourceUrl: "https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt"
    matchProfileName: "v2rayN"
    defaultProfileName: "direct"

  "+auto switch":
    profileType: "SwitchProfile"
    rules: [
      {
        condition:
          pattern: "*.cn"
          conditionType: "HostWildcardCondition"
        profileName: "direct"
      }
      {
        condition:
          pattern: "*.baidu.com"
          conditionType: "HostWildcardCondition"
        profileName: "direct"
      }
      {
        condition:
          pattern: "*.qq.com"
          conditionType: "HostWildcardCondition"
        profileName: "direct"
      }
      {
        condition:
          pattern: "*.taobao.com"
          conditionType: "HostWildcardCondition"
        profileName: "direct"
      }
      {
        condition:
          pattern: "*.jd.com"
          conditionType: "HostWildcardCondition"
        profileName: "direct"
      }
      {
        condition:
          pattern: "*.163.com"
          conditionType: "HostWildcardCondition"
        profileName: "direct"
      }
      {
        condition:
          pattern: "*.sina.com"
          conditionType: "HostWildcardCondition"
        profileName: "direct"
      }
      {
        condition:
          pattern: "*.bilibili.com"
          conditionType: "HostWildcardCondition"
        profileName: "direct"
      }
      {
        condition:
          pattern: "*.zhihu.com"
          conditionType: "HostWildcardCondition"
        profileName: "direct"
      }
      {
        condition:
          pattern: "*.douyin.com"
          conditionType: "HostWildcardCondition"
        profileName: "direct"
      }
    ]
    name: "auto switch"
    color: "#99dd99"
    defaultProfileName: "__ruleListOf_auto switch"