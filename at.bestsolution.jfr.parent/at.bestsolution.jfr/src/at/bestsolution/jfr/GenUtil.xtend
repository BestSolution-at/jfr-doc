package at.bestsolution.jfr

import at.bestsolution.jfr.jFRMeta.Clazz
import at.bestsolution.jfr.jFRMeta.Attribute
import at.bestsolution.jfr.jFRMeta.Model
import java.util.List
import java.util.HashMap
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.emf.common.util.URI
import java.util.LinkedHashMap
import java.util.Set
import java.util.Collection

class GenUtil {
	def static getEventName(Clazz cl) {
		return cl.annotations.filter[a | a.getType().getName() == "Name"].map(a | a.values.head.valueString).head
	}

	def static getLabel(Clazz cl) {
		return cl.annotations.filter[a | a.getType().getName() == "Label"].map(a | a.values.head.valueString).head
	}

	def static getDescription(Clazz cl) {
		return cl.annotations.filter[a | a.getType().getName() == "Description"].map(a | a.values.head.valueString).head
	}

	def static getCategories(Clazz cl) {
		return cl.annotations.filter[a | a.getType().getName() == "Category"].flatMap[a|a.values].map[v|v.valueString]
	}

	def static getContentType(Attribute a) {
		a.annotations.filter[an | an.type.annotations.findFirst[ca|ca.type.name == "ContentType"] !== null].head?.type?.name
	}

	def static getDescription(Attribute cl) {
		return cl.annotations.filter[a | a.getType().getName() == "Description"].map(a | a.values.head.valueString).head
	}

	def static isNewClazz(Clazz cl, Model prevModel) {
		return prevModel !== null && prevModel.classes.findFirst[c|cl.name == c.name] === null
	}

	def static isNewAttribute(Attribute att, Model prevModel) {
		val ownerClass = att.eContainer as Clazz
		return prevModel.classes.filter[ c | c.name == ownerClass.name ].flatMap[c|c.attributes].findFirst[a|a.name == att.name] === null
	}

	def static createModelMap() {
		val versions = newArrayList("11","12","13","14","15","16","17")
		val injector = new JFRMetaStandaloneSetup().createInjectorAndDoEMFRegistration();
		val resourceSet = injector.getInstance(XtextResourceSet);
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);

		val models = new LinkedHashMap
		for( v : versions ) {
			val resource = resourceSet.getResource(
			    URI.createURI("file:/Users/tomschindl/git/jfr-doc/openjdk-"+v+".jfr"), true);
			val model = resource.getContents().head as Model;
			models.put(v,model)
		}
		return models
	}

	def static htmlHeader(Collection<String> versions) '''
		<div uk-sticky="sel-target: .uk-navbar-container; cls-active: uk-navbar-sticky">
			<nav class="uk-navbar-container" uk-navbar>
			    <div class="uk-navbar-left">
			    	<a class="uk-navbar-item uk-logo" href="index.html">
			    		<img uk-svg="" src="beso.png" class="uk-margin-small-right" width="40">
			    		JFR-Events
			    	</a>
			    </div>

			    <div class="uk-navbar-right">

			        <ul class="uk-navbar-nav">
			            <li>
			                <a href="#">JDK-Version</a>
			                <div class="uk-navbar-dropdown">
			                    <ul class="uk-nav uk-navbar-dropdown-nav">
			                    	<li><a href="openjdk-matrix.html">OpenJDK Matrix</a></li>
			                    	«FOR v : versions»
			                    		<li><a href="openjdk-«v».html">OpenJDK «v»</a></li>
			                    	«ENDFOR»
			                    </ul>
			                </div>
			            </li>
			            <li><a href="https://github.com/BestSolution-at/jfr-doc">About</a></li>
			        </ul>

			    </div>
			</nav>
		</div>
	'''

	def static htmlFooter() '''
		<div class="uk-container uk-container-small uk-position-relative">
			<p style="text-align: center">&copy; <a href="http://www.bestsolution.at">BestSolution.at</a></p>
		</div>
	'''
}