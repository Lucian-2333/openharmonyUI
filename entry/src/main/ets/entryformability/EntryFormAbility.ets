import { Want, common } from '@kit.AbilityKit'
import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { DeviceStateRepository } from '../store/DeviceStateRepository'

const TAG: string = 'EntryFormAbility'

class EmptyFormPayload {
}

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    if (!want.parameters) {
      return formBindingData.createFormBindingData(new EmptyFormPayload())
    }

    let formId = String(want.parameters[formInfo.FormParam.IDENTITY_KEY])
    let formName = String(want.parameters[formInfo.FormParam.NAME_KEY])
    void DeviceStateRepository.registerForm(this.context as common.Context, formId, formName)
      .then(() => DeviceStateRepository.syncForm(this.context as common.Context, formId, formName))
      .catch((error: Object) => {
        hilog.error(0x0000, TAG, `onAddForm register failed: ${JSON.stringify(error)}`)
      })
    return DeviceStateRepository.createFormBinding(formName, DeviceStateRepository.restoreDevices(''))
  }

  onUpdateForm(_formId: string): void {
    let context = this.context as common.Context
    void DeviceStateRepository.syncRegisteredForms(context)
  }

  onFormEvent(_formId: string, message: string): void {
    try {
      let msg = JSON.parse(message) as Record<string, string>
      if (msg.operation === 'toggle' && msg.deviceId) {
        void DeviceStateRepository.toggleDevice(this.context as common.Context, Number(msg.deviceId))
          .then(() => {
            hilog.info(0x0000, TAG, `toggle from card, deviceId=${msg.deviceId}`)
          })
          .catch((error: Object) => {
            hilog.error(0x0000, TAG, `toggle from card failed: ${JSON.stringify(error)}`)
          })
      }
    } catch (error) {
      hilog.error(0x0000, TAG, `parse form message failed: ${JSON.stringify(error)}`)
    }
  }

  onRemoveForm(formId: string): void {
    void DeviceStateRepository.unregisterForm(this.context as common.Context, formId)
  }

  onAcquireFormState(_want: Want): formInfo.FormState {
    return formInfo.FormState.READY
  }
}
